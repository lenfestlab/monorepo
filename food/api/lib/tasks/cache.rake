namespace :cache do

  desc "import nabes from geojson"
  task refresh: :environment do
    Category.all.each &:save!
  end

end

