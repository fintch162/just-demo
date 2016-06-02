class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :phone_number
      t.datetime :msg_time
      t.text :msg_des
      t.integer :unread_count
      t.integer :total_count

      t.timestamps
    end
  end
end
