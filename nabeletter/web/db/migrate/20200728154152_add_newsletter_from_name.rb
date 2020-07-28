class AddNewsletterFromName < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletters, :sender_name, :string
    add_column :newsletters, :sender_address, :string
  end
end
