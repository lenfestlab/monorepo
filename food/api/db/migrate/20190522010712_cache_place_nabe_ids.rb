class CachePlaceNabeIds < ActiveRecord::Migration[5.2]
  def change
    change_table :places do |t|
      t.string :cached_nabe_identifiers, array: true
      t.index :cached_nabe_identifiers, using: :gin
    end
  end
end
