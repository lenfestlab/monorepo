class Place < ApplicationRecord

  has_many :bookmarks

  has_and_belongs_to_many :posts

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  validates :name, :address, :lat, :lng,
    presence: true

  validates :lonlat, uniqueness: true


  ## PostGIS
  #

  def find_nabes
    Nabe.covering self.lat, self.lng
  end

  def self.format lng, lat
    "POINT(#{lng} #{lat})"
  end

  before_validation do
    if lat && lng && lonlat.nil?
      self.lonlat = self.class.format lon, lat
    end
  end

  def self.default_search_radius # km
    ENV["DEFAULT_SEARCH_RADIUS"].to_i || 200
  end

  scope :nearest, -> (lat, lng, sort = nil, kilometers = Place.default_search_radius) {
    sort = sort.try(:to_sym) || :distance
    distance_sql = "ST_Distance(lonlat, 'POINT(#{lng} #{lat})')"
    chosen_sort_sql = {
      rating: "places.post_rating DESC",
      latest: "places.post_published_at DESC"
    }[sort.to_sym]
    order_sql =
      [chosen_sort_sql].flatten.compact
      .concat([distance_sql])
      .join(", ")
    select("*", %{ #{distance_sql} as distance })
      .where(%{ #{distance_sql} < #{kilometers * 1000.0} })
      .order(order_sql)
  }

  scope :located_in, -> (nabe_uuids) {
    return unless nabe_uuids.present?
    # https://postgis.net/docs/ST_Union.html
    # https://gis.stackexchange.com/a/704
    subquery = Nabe.union_geog_of(nabe_uuids).to_sql
    where("ST_Covers((#{subquery}), lonlat)", nabe_uuids)
  }


  ## Cache
  #

  def reset_nabe_cache
    self.nabe_cache = find_nabes.as_json
  end

  def nabes
    nabe_cache
  end

  def update_cache
    self.category_identifiers = categories.map(&:identifier)
    latest_post = self.post
    self.post_rating = latest_post.try(:rating) || -1
    self.post_published_at = latest_post.try(:published_at)
    if author = latest_post.try(:author)
      self.author_identifiers = [author.identifier]
    end
    self.reset_nabe_cache
  end
  before_save :update_cache
  after_touch :save


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

  scope :categorized_in, -> (uuids) {
    if uuids.present?
      where("places.category_identifiers && ARRAY[?]::varchar[]", uuids)
    end
  }

  scope :reviewed_by, -> (uuids) {
    if uuids.present?
      where("places.author_identifiers && ARRAY[?]::varchar[]", uuids)
    end
  }

  scope :bookmarked, -> (ids) {
    if ids.present?
      where 'id IN (?)', ids
    end
  }



  ## Admin
  #

  rails_admin do

    [:identifier, :created_at, :updated_at, :lonlat].each do |hidden_attr|
      configure hidden_attr do
        read_only true
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
      only: %i[
        identifier
        name
        address
        distance
        website
        phone
      ],
      methods: %i[
        location
        post
        categories
        nabes
      ]
    }.merge(options || {}))
  end

end
