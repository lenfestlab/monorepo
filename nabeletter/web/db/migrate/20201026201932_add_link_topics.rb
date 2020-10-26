class AddLinkTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :links, :redirect, :string
    %i[ topic subtopic ].each do |col|
      add_column :links, col, :string
      add_index :links, col
    end
  end
end
