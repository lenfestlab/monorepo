class CreateAds < ActiveRecord::Migration[6.0]
  def change
    create_table :ads do |t|
      t.belongs_to :newsletter
      t.string :title
      t.text :body
      t.string :screenshot_url
      t.string :logo_image_url
      t.string :main_image_url
      t.timestamps
    end
  end
end
