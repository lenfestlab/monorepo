class CreateNotifications < ActiveRecord::Migration[5.2]

  def change
    change_table :users do |t|
      t.string :gcm_token
      t.index :gcm_token
    end
    create_table :notifications do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.belongs_to :post
      t.belongs_to :user
      t.datetime :deliver_at, index: true
      t.integer :state, index: true
      t.string :title
      t.text :body
      t.timestamps
    end
  end

end
