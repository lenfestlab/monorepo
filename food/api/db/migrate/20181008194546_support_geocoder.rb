class SupportGeocoder < ActiveRecord::Migration[5.2]
  def change
    # https://git.io/fxZ1Y
    add_index :places, [:lat, :lng]
  end
end
