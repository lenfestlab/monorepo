class AddNabesPlaces < ActiveRecord::Migration[5.2]
  def change
    change_table :places do |t|
      t.belongs_to :nabe, index: true
    end
    change_table :nabes do |t|
      t.integer :places_count, index: true
    end
  end
end
