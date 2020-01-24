class CreateEditions < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletters do |t|
      t.string :name, index: true, unique: true
      t.string :mailgun_list_identifier, index: true, unique: true
      t.timestamps
    end
    create_table :editions do |t|
      t.datetime :publish_at, index: true
      t.integer :state, index: true
      t.string :subject, index: true
      t.text :body_html
      t.text :body_data, array: true, default: []
      t.belongs_to :newsletter
      t.timestamps
    end
    create_table :subscriptions do |t|
      t.string :email_address, index: true
      t.string :name_first, index: true
      t.string :name_last, index: true
      t.belongs_to :newsletter
      t.datetime :subscribed_at, index: true
      t.datetime :unsubscribed_at, index: true
      t.timestamps
    end
  end
end
