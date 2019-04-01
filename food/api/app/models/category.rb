class Category < ApplicationRecord

  validates :key, :name,
    presence: true,
    uniqueness: true

  has_many :categorizations, dependent: :destroy
  has_many :places, through: :categorizations

  # save associated places to update cached category_ids
  after_save :update_places
  def update_places
    self.places.map &:save!
  end

  def image_url
    Post.ensure_https read_attribute(:image_urls).first
  end


  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i{
      identifier
      created_at
      updated_at
      categorizations
      image_urls
    }.each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

    configure :image_url do
      read_only true
      pretty_value do
        url = bindings[:object].image_url
        bindings[:view].tag(:img, { src: url, width: "50%"})
      end
    end
  end

  def admin_name
    name
  end

  ## Filters
  #

  scope :cuisine, -> (value) {
    if value.present?
      where(is_cuisine: value)
    end
  }

  def as_json(options = nil)
    super({
      only: [
        :identifier,
        :is_cuisine,
        :name,
      ],
      methods: [
        :image_url,
      ]
    }.merge(options || {}))
  end

end
