class ApiPlaceTriggerRadius < ActiveRecord::Migration[5.2]
  def change
    change_table :places do |t|
      t.integer :trigger_radius
    end
  end
end
