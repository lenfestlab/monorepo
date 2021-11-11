class AddEditionEmailUnshortened < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :email_html_en_preprocessed, :text
  end
end
