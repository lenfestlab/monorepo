class Place < ApplicationRecord

  has_many :posts
  has_many :categorizations
  has_many :categories, through: :categorizations

  validates :name, :address, :lat, :lng,
    presence: true

  validates :name, uniqueness: true


  ## Geo
  #

  reverse_geocoded_by :lat, :lng

  def self.default_search_radius # km
    ENV["DEFAULT_SEARCH_RADIUS"].to_i || 200
  end

  # NOTE: AR.includes incompat w/ geocoder:
  # https://git.io/fxZrb
  scope :preloaded_near, -> (coordinates) {
    near(coordinates, Place.default_search_radius, units: :km)
      .joins(:posts)
      .preload(:posts)
  }


  ## Admin
  #

  rails_admin do

    [:identifier, :created_at, :updated_at].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

  end


  ## Serialization
  #

  def location
    { lat: lat, lng: lng }
  end

  def post
    posts.first
  end

  [:title, :blurb].each do |attr|
    define_method(attr) do
      Post.ensure_present(read_attribute(attr)) ||
        Post.ensure_present(post.send(attr))
    end
  end


  def as_json(options = nil)
    super({
      only: [
        :identifier,
      ],
      methods: [
        :location,
        :post,
      ]
    }.merge(options || {}))
  end

end
