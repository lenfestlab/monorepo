class AddPostPublicationNameAndTwitter < ActiveRecord::Migration[5.2]
  def change
    %w{ name twitter }.each do |publication_attr|
      add_column :posts, "publication_#{publication_attr}", :string
    end
  end
end
