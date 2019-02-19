class CreateInstallations < ActiveRecord::Migration[5.2]
  def change
    create_table :installations do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :icloud_id, index: true
      t.string :email, index: true
      t.uuid :auth_token, default: 'uuid_generate_v4()' , index: true
      t.timestamps
    end
  end
end
