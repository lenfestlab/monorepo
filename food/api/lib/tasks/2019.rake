namespace :seed do

  desc "import 2019 guide"
  task current: :environment do

dir = Rails.root.join("lib", "data", "2019")
return unless dir

def json filedir, filename
  JSON.parse(File.read("#{filedir}/#{filename}.json"))
end

def nil_if_empty str
  if str && str.present?
    str
  else
    nil
  end
end

# scope top25 category by year
if top2018 = Category.find_by(key: "top25")
  top2018.update_attributes! key: "top25-2018", name:  "Top 25 '18"
end

_json = json(dir, "diningguide2019")
_json.each do |i|

  raw_db_id = Integer(i['Id'])
  db_id = raw_db_id unless (raw_db_id == 0) # ignore 0 values == unmatched

  street_raw = i["Address"]
  throw "address MIA" unless street_raw
  # normalize: "St" => "St."
  address_street_with_number = street_raw.gsub(/\s(St|Rd|Ave)$/) {|match| "#{match}."}
  city, state_zip = i["City"], i["State"]
  state, zip = state_zip.split
  address = [address_street_with_number, city, state].join(", ")

  name = i["Name"]
  phone = nil_if_empty i["Phone"]
  website = nil_if_empty i["Website"]
  reservations_url = nil_if_empty i["Reservations"]

  phototag = i["Phototag"]

  place_attrs = {
    id: db_id,
    name: name,
    address: address, # full address for display
    address_street_with_number: address_street_with_number,
    lat: Float(i["Lat"]),
    lng: Float(i["Lng"]),
    address_city: city,
    address_zip: zip,
    address_state: state,
    phone: phone,
    website: website,
    reservations_url: reservations_url
  }

  if db_id.present?
    place = Place.find(db_id)
  else
    place = Place.create(place_attrs)
  end


  # Post

  Time.zone = 'Eastern Time (US & Canada)'
  guide_date = Time.zone.parse('2019-10-17')
  guide_author = Author.find_by! last: "LaBan"

  source_key = i["Phototag"]
  prices = i["Price"].try(:split, /,\s*/).try(:map, &:length) || []

  rating = i["Bells"].try(:strip).try(:size) || -1 # default, -1 == unrated

  #TODO: ? if contains "no", assume assigned 0 bells
  # rating = 0 if rating_text && rating_text.match?(/no/i)
  # if rating_text
    # if (rating_match = rating_text.match(/\*/))
      # if (rating_raw = rating_match[0])
         # rating = Integer(rating_raw)
      # end
    # end
  # end

  # extract list/guide keys
  standard_keys = <<EOF
Name
Lat
Lng
Address
City
State
Phone
Website
Reservations
Neighborhood
PreviousCoverage
Id
Phototag
Favorite
Bells
Price
category
EOF
  list_keys = i.keys - standard_keys.split(/\s+/)
  blurb = ""
  list_keys.each do |key|
    blurb << "[#{key}]\n"
    content = i[key]
    blurb <<
      (content["text"] || [])
      .select {|node| node["type"] == "text" }
      .map {|node| node["value"]}
      .join("\n")
        .concat("\n\n")

    unless category = Category.find_by(key: key)
      category =
        Category.create!(
          key: key,
          name: key,
          display_starts: guide_date,
          source_key: content["specialgallery"],
          is_craving: (key != "top25")
      )
    end
    Categorization.create(place: place, category: category)
  end

  post_attrs = {
    author: guide_author,
    published_at: guide_date,
    prices: prices,
    rating: rating,
    source_key: source_key,
    blurb: blurb,
    live: false,
    previously_reviewed: db_id.present?,
    previously_unreviewed: db_id.nil?,
    is_2019_top_25: list_keys.include?("top25")
  }
  # if already reviewed, copy over prior review's editorial fields
  if db_id
    prior_post = place.posts.last
    Post.md_fields.each do |field|
      post_attrs[field] = prior_post.send(field)
    end
    post_attrs[:url] = prior_post.url
    post_attrs[:prices] ||= prior_post.prices
    post_attrs[:rating] ||= prior_post.rating
  end
  place.posts.create! post_attrs
end

  end
end

=begin

_photos = json(dir, "photos")
_photos.reduce({}) { |map, o|
  key = o["keywords"]
  resource = o["resource"]
  filename = URI.escape(o["filename"])
  url = Post.ensure_https()
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

=end
