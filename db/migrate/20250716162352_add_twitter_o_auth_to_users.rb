class AddTwitterOAuthToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :twitter_uid, :string
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end
end
