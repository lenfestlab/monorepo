class Place < ApplicationRecord

  has_many :posts
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  validates :name, :address, :lat, :lng,
    presence: true

  validates :name, uniqueness: true

  ## PostGIS
  #
  #

  before_save do
    if lat && lng && lonlat.nil?
      self.lonlat = "POINT(#{lng} #{lat})"
    end
  end

  def self.default_search_radius # km
    ENV["DEFAULT_SEARCH_RADIUS"].to_i || 200
  end

  scope :nearest, -> (lat, lng, kilometers = Place.default_search_radius) {
    distance_calc = "ST_Distance(lonlat, 'POINT(#{lng} #{lat})')"
    select("places.*, #{distance_calc}")
      .where("#{distance_calc} < #{kilometers * 1000.0}")
      .order("#{distance_calc} ASC")
  }


  ## Filters
  #

  scope :rated, -> (ratings) {
    ratings = [ratings].flatten.compact
    if ratings.present?
      includes(:posts).references(:posts)
        .where 'posts.rating IN (?)', ratings
    end
  }


  scope :priced, -> (prices) {
    prices = [prices].flatten.compact
    if prices.present?
      includes(:posts).references(:posts)
        .where 'posts.price && ARRAY[?]', prices
    end
  }


  def update_category_identifiers
    self.category_identifiers = categories.map(&:identifier)
  end
  before_save :update_category_identifiers
  after_touch :save


  scope :categorized_in, -> (uuids) {
    if uuids.present?
      where("places.category_identifiers && ARRAY[?]::varchar[]", uuids)
    end
  }


  ## Admin
  #

  rails_admin do

    [:identifier, :created_at, :updated_at, :lonlat].each do |hidden_attr|
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
        :name,
        :address,
      ],
      methods: [
        :location,
        :post,
        :categories,
      ]
    }.merge(options || {}))
  end

end
