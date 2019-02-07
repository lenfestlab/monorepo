class AddUuids < ActiveRecord::Migration[5.2]
  def change
    # enable UUIDs
    enable_extension 'uuid-ossp'

    [:posts, :places].each do |table_name|
      add_column table_name, :identifier, :uuid, default: 'uuid_generate_v4()'
    end

  end
end
