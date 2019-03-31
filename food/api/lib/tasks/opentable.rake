namespace :opentable do

  desc "sync opentable directory"
  task pull: :environment do
    #TODO: GET country: "US", limit: 100, offset: n
  end

  desc "mach opentable venues with our places"
  task match: :environment do

    Place.all.each do |place|

      zip = place.address_zip
      number =  \
        place.address_number || \
        place.address.split(/\s+/).first

      raise "MIA: address number" unless address_number.present?

      # if zip and street number match, assume same venue
      if venue =
          ReservationVenue
            .where(zip: zip)
            .where(%{address_street_with_number ~* '^#{number}'})
        place.reservation_venue = venue
        place.save!
      end

    end

  end

end
