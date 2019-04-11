class Author < ApplicationRecord

  has_many :posts, dependent: :destroy

  validates :first, :last,
    presence: true

  validates :last,
    uniqueness: true

  def full_name
    [first, last].join(" ")
  end


  ## Cache
  #

  # save associated places to update cached category_ids
  after_save :update_associations
  after_destroy :update_associations
  def update_associations
    self.posts.map &:save!
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i{
      identifier
      created_at
      updated_at
    }.each do |attr|
      configure attr do
        hide
      end
    end

  end

  def admin_name
    full_name
  end


  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: %i[
        identifier
        first
        last
      ]
    }.merge(options || {}))
  end

end
