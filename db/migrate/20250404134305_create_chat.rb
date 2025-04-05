class CreateChat < ActiveRecord::Migration[6.1]
  def change
      create_table :chats do |t|
        t.string :chat, null: false
        t.string :name, null: false
        t.timestamps null:false
      end
  end
end
