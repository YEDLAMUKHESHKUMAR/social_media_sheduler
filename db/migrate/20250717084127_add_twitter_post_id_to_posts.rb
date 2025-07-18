class AddTwitterPostIdToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :twitter_post_id, :string
  end
end
