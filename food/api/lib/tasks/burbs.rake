raise "cannot seed prod" if Rails.env == "production"

def json filedir, filename
  JSON.parse(File.read("#{filedir}/#{filename}.json"))
end

namespace :seed do

  desc "import 2017 Guide (suburbs)"
  task burbs: :environment do

    dir = ENV["ADMIN_DB_SEED_DIR"]
    raise "MIA: ADMIN_DB_SEED_DIR env var" unless dir
    dir = "#{dir}/2017"

    # common values
    Time.zone = 'Eastern Time (US & Canada)'
    guide_author = Author.find_by! last: "LaBan"
    guide_published_at = Time.zone.parse('2017-10-19')
    guide_url = 'https://media.philly.com/storage/special_projects/philadelphia-suburbs-best-restaurants-bars-food-map.html'


    # guides
    category_top_key = "top-25-2017"
    _category_top =
      Category.find_by_key(category_top_key) ||
      Category.create(
        key: category_top_key,
        name: 'Top Restaurants in Philly’s Suburbs',
        image_urls: [
          "https://media.philly.com/storage/special_projects/images/RS_1500x1500_20171016_DG_FARMFISHERMAN19_d_418124950.jpg"
        ]
      )

    _photo_index =
      json(dir, "photos").reduce({}) do |hash, o|
        key = o["notes"]
        resource = o["resource"]
        filename = URI.escape(o["filename"])
        url = "https://media.philly.com/storage/inquirer/Graphics/dg-suburbs/RS#{resource}_#{filename}"
        caption, credit = o.values_at(*%w{ caption credit })
        existing = hash[key]
        addition = [{url: url, caption: caption, credit: credit}]
        hash[key] = existing.present? ? existing.concat(addition) : addition
        hash
      end
    ap _photo_index

    _categories_index =
      json(dir, "categories").reduce({}) { |hash,  i|
        puts "\n"
        _key, _county, _image_url = i.values_at(*%w{ key county photo_tag })
        if _county.present? # county guide
          key = _county
        elsif _key.present? # "other" guide (eg Pizza)
          key = _key
        end
        if _image_url.present?
          image_url = Post.ensure_https _image_url
        end
        additions = [image_url].compact
        existing = hash[key]
        image_urls = existing.present? ? existing[:image_urls].concat(additions) : additions
        hash[key] = { key: key, name: key, image_urls: image_urls }
        hash
      }
    ap _categories_index

    _places = json(dir, "restaurant-data-cleaned")
    _places.each do |i|

      puts "\n"

      name, phone, website = i.values_at(*%w{ Name Phone URL })
      address = i.values_at(*%w{ Address City State Zip }).join(", ")
      lat, lng = i.values_at(*%w{ lat lng })
      place_attrs = {
          lat: lat,
          lng: lng,
          address: address,
          name: name,
          phone: phone,
          website: website,
          address_street_with_number: i["Address"],
          address_city: i["City"],
          address_state: i["State"],
          address_county: i["County"],
          address_zip: i["Zip"],
      }
      ap place_attrs
      next unless lat.present? && lng.present?
      place =
        Place.find_or_create_by!(lonlat: Place.format(lng, lat)) do |place|
          place.assign_attributes(place_attrs)
          ap place
        end

      # Categories
      potential_category_keys =
        i.values_at(*%w{ category filter})
        .compact
        .map { |i| i.split(/,\s?/) }
        .flatten
        .compact
      category_keys = potential_category_keys & _categories_index.keys
      category_keys.each do |raw_key|
        attrs = _categories_index[raw_key]
        normalized_key = raw_key.parameterize
        category = Category.find_or_create_by(key: normalized_key) do |c|
          c.name = attrs[:name]
          c.image_urls = c.image_urls.concat(attrs[:image_urls])
        end
        Categorization.create(place: place, category: category) end

      blurb, _rating, _prices, _url, _photo_key =
        i.values_at(*%w{ from_hermes Bells price county_page photo_tag })
      # NOTE: 2017 guide doesn't have "no bells" entries: assume empty is unrated
      rating = -1
      if _rating.present?
         count = _rating.scan(/bell/i).length
         rating = (count == 0) ? -1 : count
      end
      prices = _prices.split(/-/).map { |i| i.scan(/\$/).length }
      url = Post.ensure_https(_url || guide_url)
      images = _photo_index[_photo_key] || []

      post_attrs = {
        author: guide_author,
        published_at: guide_published_at,
        blurb: blurb,
        prices: prices,
        rating: rating,
        url: url,
        images: images,
      }
      ap post_attrs

      post = Post.find_or_create_by!(blurb: blurb) do |p|
        p.assign_attributes(post_attrs.except(:blurb))
      end
      unless place.posts.include?(post)
        place.posts << post
        place.save!
      end

      parse_bool = Proc.new { |text| text.present? && (text == "yes")  }
      if parse_bool.call(i["favorite"])
        Categorization.create(place: place, category: _category_top)
      end
    end

  end

end

