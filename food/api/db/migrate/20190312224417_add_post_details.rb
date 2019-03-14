class AddPostDetails < ActiveRecord::Migration[5.2]
  def change
    change_table(:posts) do |t|
      t.text :md_place_summary
      t.text :md_menu
      t.text :md_drinks
      t.text :md_notes
      t.text :md_reservations
      t.text :md_accessibility
      t.text :md_parking
      t.text :md_price
    end
  end
end
