class CachePlaceReviewers < ActiveRecord::Migration[5.2]
  def change
    change_table :places do |t|
      t.string :author_identifiers, array: true, default: []
      t.index :author_identifiers
    end
  end
end
