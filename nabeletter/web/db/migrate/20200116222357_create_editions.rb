class CreateEditions < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletters do |t|
      t.string :name, index: true, unique: true
      t.timestamps
    end
    create_table :editions do |t|
      t.datetime :publish_at, index: true
      t.integer :state, index: true
      t.string :subject, index: true
      t.text :body_html
      t.text :body_data, array: true, default: []
      t.belongs_to :newsletter
      t.timestamps
    end
  end
end
