class PlaceAddressElements < ActiveRecord::Migration[5.2]
  def change
    change_table :places do |t|
      %i[
        number
        street
        city
        county
        state
        zip
        country
        street_with_number
      ].each do |column_name|
        t.string "address_#{column_name}", index: true
      end
    end
  end
end
