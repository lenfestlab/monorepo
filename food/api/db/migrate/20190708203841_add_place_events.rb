class AddPlaceEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :place_events do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.belongs_to :user
      t.belongs_to :place
      %i[
      last_viewed_at
      last_entered_at
      last_exited_at
      last_visited_at
      ].each do |attr|
        t.datetime attr
        t.index attr
      end
      t.timestamps
    end
  end
end
