class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.string :title, index: true
      t.text :pre
      t.text :post
      t.text :sections, array: true, default: []
      t.timestamps
    end
    create_table :page_sections do |t|
      t.string :title, index: true
      t.text :body
      t.belongs_to :page
      t.timestamps
    end
  end
end
