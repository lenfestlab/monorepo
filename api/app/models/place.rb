class Place < ApplicationRecord

  belongs_to :post,
    # NOTE: omit inverse_of as rec'd by rails_admin docs, else complex form:
    # https://screenshots.brent.is/1538661448.png
    #inverse_of: :places,
    dependent: :destroy,
    touch: true

  validates :lat, :lng,
    presence: true

  reverse_geocoded_by :lat, :lng

  def self.default_search_radius # km
    ENV["DEFAULT_SEARCH_RADIUS"].to_i || 200
  end

  # NOTE: AR.includes incompat w/ geocoder:
  # https://git.io/fxZrb
  scope :preloaded_near, -> (coordinates) {
    near(coordinates, Place.default_search_radius, units: :km)
      .joins(:post)
      .preload(:post)
  }


  delegate :url, to: :post

  [:title, :blurb, :radius].each do |attr|
    define_method(attr) do
      read_attribute(attr) ||
        post.send(attr) ||
        Post.default_trigger_radius
    end
  end

  def image_url
    Post.ensure_https(read_attribute(:image_url)) || post.image_url
  end

  def location
    { lat: lat, lng: lng }
  end

  def as_json(options = nil)
    super({
      only: [
        :identifier,
      ],
      methods: [
        :title,
        :blurb,
        :image_url,
        :location,
        :radius,
        :post
      ]
    }.merge(options || {}))
  end

  rails_admin do

    configure :identifier do
      hide
    end

    visible false # hide from nav: https://git.io/fxmGi

    # omit parent Post field from edit/show
    list do
      configure :post do
        show
      end
    end
    edit do
      configure :post do
        hide
      end
    end

    object_label_method :admin_name

    edit do
      include_fields :lat, :lng
      [:title, :blurb, :image_url, :radius].each do |attr|
        field attr do
          help "Optional. Only use to override the parent Post value above in notifications."
        end
      end
    end
  end


  def admin_name
    "@#{lat},#{lng}"
  end

end
