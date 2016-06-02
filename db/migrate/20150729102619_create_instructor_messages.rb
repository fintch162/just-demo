class CreateInstructorMessages < ActiveRecord::Migration
  def change
    create_table :instructor_messages do |t|
      t.string :to_number
      t.text :msg_des
      t.string :unique_message_id
      t.string :phone_id
      t.string :direction
      t.string :status
      t.string :project_id
      t.string :message_type
      t.string :source
      t.string :from_number
      t.integer :starred
      t.datetime :time_created
      t.string :message_status
      t.references :instructor, index: true

      t.timestamps
    end
  end
end
