class AddNewsletterBackgroundImageUrl < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletters, :signup_background_image_url, :string
    add_column :newsletters, :theme_foreground_color, :string
  end
end
