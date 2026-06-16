class AddEmojiToLikes < ActiveRecord::Migration[8.1]
  def change
    add_column :likes, :emoji, :string, null: false, default: "❤️"

    # Expand unique scope: a user may now react with multiple different emojis on the same item.
    remove_index :likes, [ :user_id, :likeable_type, :likeable_id ], if_exists: true
    add_index    :likes, [ :user_id, :likeable_type, :likeable_id, :emoji ],
                 unique: true, name: "index_likes_on_user_likeable_emoji"
  end
end
