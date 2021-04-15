class AddPageNewsletter < ActiveRecord::Migration[6.0]
  def change
    change_table :pages do |t|
      t.belongs_to :newsletter
      t.string :header_image_url
    end
  end
end
