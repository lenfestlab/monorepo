class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :uid, index: true
      t.string :ea, index: true
      t.string :ec, index: true
      t.string :el, index: true
      t.string :cd1, index: true
      t.string :cd2, index: true
      t.string :cd3, index: true
      t.string :cd4, index: true
      t.string :cd5, index: true
      t.string :cd6, index: true
      t.string :cd7, index: true
      t.string :cd8, index: true
      t.timestamps
    end
  end
end
