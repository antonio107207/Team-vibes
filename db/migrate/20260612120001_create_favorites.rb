class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user,        null: false, foreign_key: true
      t.references :hobby_entry, null: false, foreign_key: true
      t.timestamps
    end
    add_index :favorites, [ :user_id, :hobby_entry_id ], unique: true
  end
end
