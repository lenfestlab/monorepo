class AddEditionDeliveriesCount < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :stat_delivered, :integer
  end
end
