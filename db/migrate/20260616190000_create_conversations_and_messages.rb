class CreateConversationsAndMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :sender,    null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :conversations, %i[sender_id recipient_id], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender,       null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.datetime :read_at
      t.timestamps
    end
    add_index :messages, %i[conversation_id read_at]
    add_index :messages, %i[conversation_id created_at]
  end
end
