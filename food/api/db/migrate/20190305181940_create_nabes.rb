class CreateNabes < ActiveRecord::Migration[5.2]
  def change
    create_table :nabes do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :key, index: true
      t.string :name
      t.geometry :geog, geographic: true
      t.timestamps
      t.index :geog, using: :gist
    end
  end
end
