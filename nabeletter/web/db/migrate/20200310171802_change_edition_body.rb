class ChangeEditionBody < ActiveRecord::Migration[6.0]
  def change
    remove_column :editions, :body_data
    add_column :editions, :body_data, :jsonb, default: {}
  end
end
