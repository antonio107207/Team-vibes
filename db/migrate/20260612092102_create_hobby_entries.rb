class CreateHobbyEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :hobby_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :category
      t.string :title
      t.text :description
      t.integer :rating

      t.timestamps
    end
  end
end
