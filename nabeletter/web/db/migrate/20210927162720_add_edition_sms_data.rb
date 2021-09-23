class AddEditionSmsData < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :sms_data, :jsonb, default: {}
  end
end
