class AddPageOrderedSections < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :ordered_section_ids, :integer, array: true, default: []
  end
end
