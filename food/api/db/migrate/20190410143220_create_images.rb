class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :url, index: true
      t.string :credit
      t.string :caption
    end

    %w( post category ).each do |tn|
      table_name = tn.pluralize
      create_join_table :images, table_name do |t|
        t.index :image_id
        t.index "#{tn}_id"
        t.bigserial :insert_id, null: false, unique: true
      end
      change_table table_name do |t|
        t.jsonb :cached_images, array: true, default: []
        t.index :cached_images, using: :gin
      end
    end

  end
end
