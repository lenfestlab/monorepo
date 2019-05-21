require 'rgeo/geo_json'

namespace :seed do

  desc "import nabes from geojson"
  task nabes: :environment do
    city_names =
      Place.all.pluck(:address_city)
      .compact # remove nils
      .sort
      .uniq # distinct values
    city_names.delete('Philadelphia')
    city_names.each do |name|
      unless Nabe.where("name ILIKE :search", search: name.downcase).present?
        Nabe.create! name: name
      end
    end
  end

end

