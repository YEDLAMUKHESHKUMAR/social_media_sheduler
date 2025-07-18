class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.datetime :scheduled_at
      t.datetime :published_at
      t.string :status
      t.string :platform
      t.string :linkedin_post_id

      t.timestamps
    end
  end
end
