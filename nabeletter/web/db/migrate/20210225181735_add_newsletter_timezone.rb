class AddNewsletterTimezone < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletters, :timezone, :string
  end
end
