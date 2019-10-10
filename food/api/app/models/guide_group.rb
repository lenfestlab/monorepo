class GuideGroup < ApplicationRecord

  validates :title,
    uniqueness: true,
    presence: true

  validates :priority,
    presence: true

  # see related notes in Category
  has_and_belongs_to_many :categories, -> (s) {
    order('categories_guide_groups.insert_id')
  },
  class_name: "Category",
  join_table: "categories_guide_groups",
  foreign_key: "guide_group_id",
  association_foreign_key: "category_id"
  def category_ids=(ids)
    super([])
    super(ids)
  end

  scope :prioritized, -> { order(priority: :desc) }

  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i{
      identifier
      created_at
      updated_at
    }.each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

    configure :categories do
      orderable true
    end

    list do
      scopes([:prioritized])
    end
  end

  def admin_name
    title
  end


  def as_json
    ActiveModelSerializers::SerializableResource.new(self, {}).as_json
  end

end
