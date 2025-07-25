class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :provider
      t.string :uid
      t.string :linkedin_token
      t.string :linkedin_refresh_token

      t.timestamps
    end
  end
end
