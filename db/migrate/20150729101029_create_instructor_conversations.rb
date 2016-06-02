class CreateInstructorConversations < ActiveRecord::Migration
  def change
    create_table :instructor_conversations do |t|
      t.string :phone_number
      t.datetime :msg_time
      t.text :msg_des
      t.integer :unread_count
      t.integer :total_count
      t.string :from_number
      t.string :project_id
      t.string :final_from_number
      t.references :instructor, index: true

      t.timestamps
    end
  end
end
