class AddGuideGroups < ActiveRecord::Migration[5.2]

  def change
    create_table :guide_groups do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :title
      t.string :description
      t.jsonb :cached_guides, array: true, default: []
      t.integer :priority, default: 0
    end

    %w( category ).each do |tn|
      table_name = tn.pluralize
      create_join_table :guide_groups, table_name do |t|
        t.index :guide_group_id
        t.index "#{tn}_id"
        t.bigserial :insert_id, null: false, unique: true
      end
    end


  end
end
