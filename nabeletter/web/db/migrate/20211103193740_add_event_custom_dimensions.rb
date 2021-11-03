class AddEventCustomDimensions < ActiveRecord::Migration[6.0]
  def change
    %w{ 9 10 11 12 }.each do |cdn|
      col_name = "cd#{cdn}".to_sym
      add_column :events, col_name, :string
      add_index :events, col_name
    end
    add_column :deliveries, :body, :text
    %w{ es en }.each do |lang|
      add_column :editions, "sms_body_#{lang}", :text
    end
  end
end
