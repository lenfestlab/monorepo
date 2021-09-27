class AddSubscriptionChannel < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :channel, :integer, default: 0, index: true
    add_column :subscriptions, :phone, :string, index: true
    add_column :subscriptions, :e164, :string, index: true
    add_column :subscriptions, :twilio_sms_binding_sid, :string, index: true
  end
end
