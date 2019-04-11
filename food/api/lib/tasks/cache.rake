namespace :cache do

  desc "import nabes from geojson"
  task refresh: :environment do
    [Category, Post].each do  |klass|
      klass.all.each &:save!
    end
  end

end

