class AddErrorMessageToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :error_message, :text
  end
end
