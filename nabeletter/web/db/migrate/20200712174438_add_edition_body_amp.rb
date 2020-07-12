class AddEditionBodyAmp < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :body_amp, :text
  end
end
