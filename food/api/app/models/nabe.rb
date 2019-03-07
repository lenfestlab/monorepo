class Nabe < ApplicationRecord

  validates :key, :name, :geog,
    presence: true
  validates :key, uniqueness: true

  ## PostGIS
  #

  scope :union_geog_of, -> (uuids) {
    return unless uuids.present?
    select( %{
      ST_Transform(
        ST_Multi(
          ST_Union(
           ST_Transform(nabes.geog::geometry, 26910)
          )), 4326)::geography
           }
          )
            .where(identifier: uuids)
  }

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
    [:identifier, :created_at, :updated_at, :key, :geog].each do |hidden_attr|
      configure hidden_attr do
        hide
      end
    end
  end

end
