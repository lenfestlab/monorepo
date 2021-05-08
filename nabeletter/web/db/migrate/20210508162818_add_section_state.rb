class AddSectionState < ActiveRecord::Migration[6.0]
  def change
    add_column :page_sections, :hidden, :boolean, default: false, index: true
  end
end
