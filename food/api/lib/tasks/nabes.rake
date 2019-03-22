require 'rgeo/geo_json'

namespace :seed do

  desc "import nabes from geojson"
  task nabes: :environment do
    dir = ENV["ADMIN_DB_SEED_DIR"]
    raise "MIA: ADMIN_DB_SEED_DIR env var" unless dir
    data = JSON.parse(File.read("#{dir}/phl_nabes.geojson"))
    features = data["features"]
    features.each do |feature|
      props = feature["properties"].symbolize_keys!
      key = props[:name]
      name = props[:listname]
      geog_json = JSON.generate feature["geometry"]
      geog = RGeo::GeoJSON.decode(geog_json).as_text
      ap geog
      if nabe = Nabe.find_by_key(key)
        nabe.geog = geo
        nabe.save!
      else
        nabe =
          Nabe.create!({
            key: key,
            name: name,
            geog: geog
          })
      end
    end

  end

end

