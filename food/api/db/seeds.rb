raise "attempted to seed prod!" if Rails.env == "production"

dir = ENV["ADMIN_DB_SEED_DIR"]
return unless dir

def json filedir, filename
  JSON.parse(File.read("#{filedir}/#{filename}.json"))
end

_addressinfo = json(dir, "addressinfo_clean")
_addressinfo.each do |i|
  Place.create({
    name: i["name"],
    address: i["address"],
    lat: i["Latitude"],
    lng: i["Longitude"]
  })
end

# tee up shared values
Time.zone = 'Eastern Time (US & Canada)'
guide_date = Time.zone.parse('2018-10-18')

category_top25 = Category.create(key: "top25", name: "Top 25")
category_classic = Category.create(key: "classic", name: "Classic")

_data = json(dir, "data")
_reviews = _data["restaurants"]
_reviews.each do |review|
  name = review["Title"]
  place = Place.find_by_name(name)
  raise "MIA: place for #{name}, next..." unless place

  # additional Place attrs
  place.phone = review["Phone"]
  place.website = review["Website"]
  place.save!

  source_key = review["Tag"]
  price = review["Price"].try(:split, /,\s*/).try(:map, &:length)
  rating_text = review["Bells"]
  rating_match = rating_text.match(/\A\d/) if rating_text
  rating_raw = rating_match[0] if rating_match
  rating = Integer(rating_raw) if rating_raw
  blurb =
    (review["text"] || [])
    .select {|node| node["type"] == "text" }
    .map {|node| node["value"]}
    .join("\n")

  attrs = {
    place: place,
    published_at: guide_date,
    price: price,
    rating: rating,
    blurb: blurb,
    source_key: source_key,
  }
  Post.create(attrs)

  parse_bool = Proc.new { |text| text.present? && (text == "yes")  }
  if parse_bool.call(review["Top-25"])
    Categorization.create(place: place, category: category_top25)
  end
  if parse_bool.call(review["Classic"])
    Categorization.create(place: place, category: category_classic)
  end

#Leadimg

end

_categories = _data["sections"]
_categories.each do |key, obj|
  name_node = obj.find { |node| node["type"] == "text" }
  name = name_node["value"] if name_node
  places_node = obj.find { |node| node["type"] == "restaurants"}
  place_names = places_node["value"] if places_node
  next unless name && place_names.present?
  category =
    Category.find_by_key(key) ||
    Category.create(key: key, name: name)

  image_urls_node = obj.find { |node| node["type"] == "Leadimg"}
  image_url = image_urls_node["value"] if image_urls_node
  category.update_attributes!({
    image_urls: [image_url]
  })

  places = Place.where(name: place_names)
  places.each { |place| Categorization.create(place: place, category: category) }
end

_photos = json(dir, "photos")
_photos.reduce({}) { |map, o|
  key = o["keywords"]
  resource = o["resource"]
  filename = URI.escape(o["filename"])
  url = Post.ensure_https("http://media.philly.com/storage/inquirer/projects/dining-guide-2018/photos/RS#{resource}_#{filename}")
  existing = map[key]
  addition = [url]
  map[key] = existing.present? ? existing.concat(addition) : addition
  map
}.each do |source_key, images|
  if post = Post.find_by_source_key(source_key)
    post.image_urls = images
    post.save
  end
end

## Bars
# src data: https://goo.gl/svbxoM
def csv filedir, filename
  CSV.read("#{filedir}/#{filename}.csv", {
    headers: true,
    header_converters: :symbol,
  })
end

_bar_data = csv(dir, "bars")
_bar_data.each do |row|
  name = row[:name]
  place =
    Place.find_by_name(name) ||
    Place.create({
      name: name,
      address: row[:address],
      lat: row[:lat],
      lng: row[:long],
    })

  name = row[:type]
  key = name.downcase.gsub(/[[:space:]]/, '')
  category =
    Category.find_by_key(key) ||
    Category.create(key: key, name: name)
  Categorization.create(place: place, category: category)

  category.update_attributes!({
    image_urls: [row[:image]]
  })

  url = row[:link]
  attrs = {
    place: place,
    published_at: guide_date,
    blurb: row[:description],
    url: url,
    source_key: url,
    image_urls: [row[:image]]
  }

  Post.create(attrs)
end


## Cuisine
#
_cuisine_keys = %w{
seafood
italian
middleeastern
french
mexican
japanese
vegetables
modernamerican
chinese
southeastasian
dinersdelis
sandwiches
gastropubs
chops
pizza
soulfood
polish
korean
borschtbelt
latino
}
=begin
Key
top25
classic
chinatown
readingmarket
=end

_backfilled_category_images = {
  classic: "http://media.philly.com/storage/inquirer/projects/dining-guide-2018/photos/dg-classics-landingpage.jpg",
  top25: "http://media.philly.com/storage/inquirer/projects/dining-guide-2018/photos/RS1241068_AECRAIG12-A-1.JPG",
  pizza: "http://media.philly.com/storage/inquirer/projects/dining-guide-2018/photos/pizzaphoto-1.jpg",
  sandwiches: "http://media.philly.com/storage/inquirer/projects/dining-guide-2018/photos/RS1249817_DGCLASSICS18-m.jpg"
}

Category.all.each do |category|
  key = category.key
  attrs = {
    is_cuisine: _cuisine_keys.include?(key)
  }
  if image_url = _backfilled_category_images[key.to_sym]
    attrs.merge!({
      image_urls: [image_url]
    })
  end
  category.update_attributes!(attrs)
end

