class AddNewsletterLatLng < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletters, :lat, :decimal, {:precision=>10, :scale=>6}
    add_column :newsletters, :lng, :decimal, {:precision=>10, :scale=>6}
  end
end
