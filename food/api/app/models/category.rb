class Category < ApplicationRecord

  validates :name,
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
      image_url
      key
    }.each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

    show do
      configure :image_url do
        pretty_value do
          url = bindings[:object].image_url
          bindings[:view].tag(:img, { src: url, width: "50%"})
        end
      end
    end

    edit do
      configure :images, :yaml do
        label "Images [YAML]"
        html_attributes rows: 5, cols: 80, wrap: "off"
        help %{NOTE: currently only the first URL in list is rendered in app - TIP: copy/paste edits to validate: http://yaml-online-parser.appspot.com }
        pretty_value do
          data = bindings[:object].images
          bindings[:view].render(
            partial: "post_images_data",
            locals: { data: data }
          )
        end
      end
    end

  end

  def admin_name
    name
  end

  def images
    image_urls
  end
  def images= data
    write_attribute(:image_urls, data.compact)
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
