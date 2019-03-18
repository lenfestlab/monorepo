class AddPlaceNabeCache < ActiveRecord::Migration[5.2]
  def change
    change_table(:places) do |t|
      t.jsonb :nabe_cache, array: true, default: []
      t.index :nabe_cache, using: :gin
    end
  end
end
