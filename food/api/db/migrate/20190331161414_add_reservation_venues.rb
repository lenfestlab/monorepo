class AddReservationVenues < ActiveRecord::Migration[5.2]

  def change
    ## src: https://platform.opentable.com/documentation/#directory-api
    #
    #"rid": 2,
    #"name": "Thirsty Bear",
    #"address": "661 Howard St.",
    #"address2": null,
    #"city": "San Francisco",
    #"state": "CA",
    #"country": "US",
    #"latitude": "37.7856500",
    #"longitude": "-122.3997340",
    #"postal_code": "94105",
    #"phone_number": "4159740905",
    #"metro_name": "San Francisco Bay Area",
    #"is_restaurant_in_group": false,
    #"reservation_url": "http://www.opentable.com/restaurant/profile/130",
    #"profile_url": "http://www.opentable.com/restaurant/profile/130",
    #"natural_profile_url": "https://www.opentable.com/r/boulevard-san-francisco",
    #"natural_reservation_url": "https://www.opentable.com/r/boulevard-san-francisco",
    #"aggregate_score": "4.400",
    #"price_quartile": "$$",
    #"review_count": 155,
    #"category": ["Spanish", "Brewery"]
    create_table :reservation_venues do |t|
      t.string :service, index: true
      t.string :service_identifier, index: true # unique id set by service
      t.string :service_url
      t.string :name, index: true
      t.string :address_street_with_number, index: true # address
      %i[ city state country zip metro phone ].each do |column_name|
        t.string column_name, index: true
      end
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.timestamps
    end

    change_table :places do |t|
      t.belongs_to :reservation_venue
      t.string :cached_reservation_url
    end
  end

end
