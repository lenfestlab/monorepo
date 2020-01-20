class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.string :email_address, index: true
      t.string :name, index: true
      t.belongs_to :newsletter
      t.datetime :subscribed_at, index: true
      t.datetime :unsubscribed_at, index: true
      t.timestamps
    end
  end
end
