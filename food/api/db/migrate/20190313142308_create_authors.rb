class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :first
      t.string :last
      t.timestamps
    end
    change_table(:posts) do |t|
      t.belongs_to :author, index: true
    end
  end
end
