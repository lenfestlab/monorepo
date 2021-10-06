class CreateSmsNumbers < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_numbers do |t|
      t.string :e164, index: true
      t.integer :lang, default: 0, index: true
      t.integer :env, default: 0, index: true
      t.belongs_to :newsletter
      t.timestamps
    end

    create_table :twilio_events do |t|
      t.jsonb :payload, default: {}
      t.string :sms_id, null: false, index: { unique: true }
      t.belongs_to :sms_number
      t.timestamps
    end

    add_column :newsletters, :sms_reply_data, :jsonb, default: {}

    remove_column :subscriptions, :twilio_sms_binding_sid, :string

    create_table :deliveries do |t|
      t.belongs_to :edition
      t.belongs_to :subscription
      t.timestamps
    end
  end
end
