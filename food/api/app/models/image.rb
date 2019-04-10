class Image < ApplicationRecord

  has_and_belongs_to_many :posts, touch: true
  has_and_belongs_to_many :categories, touch: true

  validates(*%i[
    url
  ], presence: true)

  validates_uniqueness_of :url

  def preview
    url
  end

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
