class Image < ApplicationRecord

  has_and_belongs_to_many :posts, touch: true
  has_and_belongs_to_many :categories, touch: true

  validates(*%i[
    url
  ], presence: true)

  validates_uniqueness_of :url


  ## Cache
  #

  # save associated places to update cached category_ids
  after_save :update_associations
  after_destroy :update_associations
  def update_associations
    self.posts.map &:save!
    self.categories.map &:save!
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      identifier
      created_at
      posts
      categories
    ].each do |attr|
      configure attr do
        hide
      end
    end

    configure :preview do
      read_only true
      pretty_value do
        url = bindings[:object].url
        bindings[:view].tag(:img, { src: url, width: "50%"})
      end
    end

  end

  def admin_name
    [caption, credit, url].compact.join(" - ")
  end

  def preview
    url
  end



  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: %i[
        url
        credit
        caption
      ]
    }.merge(options || {}))
  end

end
