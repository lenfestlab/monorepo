class Category < ApplicationRecord

  validates :key, :name,
    presence: true,
    uniqueness: true

  has_many :categorizations, dependent: :destroy
  has_many :places, through: :categorizations

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
    }.each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end
    configure :image_urls do
      read_only true
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
