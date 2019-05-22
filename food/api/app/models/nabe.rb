class Nabe < ApplicationRecord

  validates :name,
    presence: true

  validates :key,
    uniqueness: true,
    if: -> { key.present? }

  validates :name,
    uniqueness: true

  after_save :update_places
  def update_places
    Place.all.each &:save!
  end


  ## PostGIS
  #

  scope :union_geog_of, -> (uuids) {
    return unless uuids.present?
    select(%{ ST_Multi(ST_Union(geog::geometry)) })
      .where(identifier: uuids)
  }

  scope :covering, -> (lat, lng) {
    return unless lat && lng
    where(%{
      ST_Covers(
        nabes.geog,
        ST_SetSRID(
          ST_Point(#{lng}, #{lat}),
          4326)
        ) })
  }

  def self.covering_place place
    lat, lng = place.lat, place.lng
    Nabe.covering lat, lng
  end

  has_many :places

  ## Serialization
  #

  def as_json(options = nil)
    super({
      only: %i{
        identifier
        name
      },
      methods: [
      ]
    }.merge(options || {}))
  end


  ## Admin
  #

  rails_admin do

    %i[
      identifier
      created_at
      updated_at
      key
      geog
      places_count
    ].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end

  end

end
