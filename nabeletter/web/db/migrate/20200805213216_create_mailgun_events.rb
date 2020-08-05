class CreateMailgunEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :mailgun_events do |t|
      t.jsonb :payload, default: {}
      t.string :mg_id, null: false, index: { unique: true }
      t.datetime :ts, index: true, precision: 6
      t.string :event, index: true
      t.string :recipient, index: true
      t.belongs_to :edition
      t.belongs_to :subscription
      t.timestamps
    end
  end
end
