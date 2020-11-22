class AddNewsletterSources < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletters, :source_urls, :text
    add_column :newsletters, :analytics_name, :string
    add_column :newsletters, :social_url_facebook, :string
    add_column :newsletters, :logo_url, :string
  end
end
