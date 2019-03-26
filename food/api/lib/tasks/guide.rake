namespace :seed do

  desc "import 2018 guide"
  task guide: :environment do

raise "attempted to seed prod!" if Rails.env == "production"

dir = File.join(ENV["ADMIN_DB_SEED_DIR"], "2018")
return unless dir

def json filedir, filename
  JSON.parse(File.read("#{filedir}/#{filename}.json"))
end

_addressinfo = json(dir, "addressinfo_clean")
_addressinfo.each do |i|
  # normalize: "St" => "St."
  street_raw = i["Street"]
  street = street_raw.gsub(/\s(St|Rd|Ave)$/) {|match| "#{match}."} if street_raw
  Place.create({
    name: i["name"],
    address: i["address"],
    lat: i["Latitude"],
    lng: i["Longitude"],
    address_number: i["Number"],
    address_street: street,
    address_city: i["City"],
    address_state: i["State"],
    address_county: i["County"],
    address_zip: i["Zip"],
    address_country: i["Country"],
  })
end

# tee up shared values
Time.zone = 'Eastern Time (US & Canada)'
guide_date = Time.zone.parse('2018-10-18')
guide_author = Author.find_by! last: "LaBan"

category_top25 = Category.create(key: "top25", name: "Top 25")
category_classic = Category.create(key: "classic", name: "Classic")

_data = json(dir, "data_clean")
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
  prices = review["Price"].try(:split, /,\s*/).try(:map, &:length)
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
    author: guide_author,
    published_at: guide_date,
    prices: prices,
    rating: rating,
    blurb: blurb,
    source_key: source_key,
  }
  ap attrs
  place.posts.create attrs

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
  caption, credit = o.values_at(*%w{ caption credit })
  existing = map[key]
  addition = [{url: url, caption: caption, credit: credit}]
  map[key] = existing.present? ? existing.concat(addition) : addition
  map
}.each do |source_key, images|
  if post = Post.find_by_source_key(source_key)
    post.images = images
    post.save
  end
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

  end
end
