class AddLang < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :lang, :integer, default: 0, index: true
    # sms
    rename_column :editions, :sms_data, :sms_data_en
    add_column :editions, :sms_data_es, :jsonb, default: {}
    # email
    rename_column :editions, :body_data, :email_data_en
    rename_column :editions, :body_html, :email_html_en
    add_column :editions, :email_data_es, :jsonb, default: {}
    add_column :editions, :email_html_es, :text
  end
end
