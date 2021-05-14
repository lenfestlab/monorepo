class AddEventAid < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :aid, :string, index: true
    add_index :events, :aid
  end
end
