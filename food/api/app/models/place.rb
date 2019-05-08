DEFAULT_TRIGGER_RADIUS = (Integer(ENV["DEFAULT_TRIGGER_RADIUS"] || 50)).freeze
DEFAULT_VISIT_RADIUS = (Integer(ENV["DEFAULT_VISIT_RADIUS"] || 50)).freeze

class Place < ApplicationRecord
  has_many :bookmarks

  has_and_belongs_to_many :posts

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  def visible_categories
    self.categories.visible
  end

  validates :name, :address, :lat, :lng,
    presence: true

  validates :lonlat, uniqueness: { scope: :name }
  validates :name,   uniqueness: { scope: %i[ address_street_with_number ] }

  before_validation :set_address
  def set_address
    unless address_street_with_number
      self.address_street_with_number = [
        self.address_number,
        self.address_street
      ].join(" ")
    end
  end

  def visit_radius
    DEFAULT_VISIT_RADIUS
  end

  def trigger_radius_with_default
    read_attribute(:trigger_radius) || DEFAULT_TRIGGER_RADIUS
  end


  ## PostGIS
  #

  attribute :distance, :float

  def location
    { lat: lat, lng: lng }
  end

  def find_nabes
    Nabe.covering self.lat, self.lng
  end

  def self.format lng, lat
    "POINT(#{lng} #{lat})"
  end

  before_validation do
    if lat && lng && lonlat.nil?
      self.lonlat = self.class.format lng, lat
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

  def latest_post
    posts.visible.sort_by(&:published_at).last
  end

  def update_cache
    self.category_identifiers = self.visible_categories.map(&:identifier)
    self.cached_categories = self.visible_categories.as_json
    self.post_rating = latest_post.try(:rating) || -1
    self.post_published_at = latest_post.try(:published_at)
    self.post_prices = latest_post.try(:prices) || []
    self.author_identifiers = [
      latest_post.try(:author).try(:identifier)
    ].compact
    self.cached_nabes = find_nabes.as_json
    self.cached_post = latest_post.as_json
  end
  before_save :update_cache
  after_touch :save


  ## Filters
  #

  scope :with_post, -> {
    where.not(post_published_at: nil)
  }

  scope :rated, -> (ratings) {
    ratings = [ratings].flatten.compact
    if ratings.present?
      where 'places.post_rating IN (?)', ratings
    end
  }


  scope :priced, -> (prices) {
    prices = [prices].flatten.compact
    if prices.present?
      where('places.post_prices && ARRAY[?]', prices)
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

  scope :bookmarked, -> (find_bookmarked, ids) {
    if find_bookmarked
      where 'id IN (?)', ids
    end
  }



  ## Admin
  #

  rails_admin do
    object_label_method :admin_name

    %i[
      created_at
      identifier
      lonlat
      post_published_at
      post_prices
      post_rating
      bookmarks
      author_identifiers
      posts
      cached_post
    ].concat(%i[
      address_number
      address_street
      address_city
      address_county
      address_state
      address_zip
      address_country
      address_street_with_number
    ]).each do |attr|
      configure attr do
        hide
      end
    end

    list do
      %i[
        phone
        website
      ].each do |attr|
        configure attr do
          hide
        end
      end
    end

    configure :trigger_radius do
      help "Meters. Optional, if blank defaults to #{DEFAULT_TRIGGER_RADIUS}"
    end

  end

  def admin_name
    %{#{name} [#{address}]}
  end

end
