class AddPostgis < ActiveRecord::Migration[5.2]
  def change
    enable_extension :postgis
    change_table(:places) do |t|
      t.st_point :lonlat, geographic: true
      t.index :lonlat, using: :gist
    end
  end
end

