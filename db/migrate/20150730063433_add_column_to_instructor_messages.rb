class AddColumnToInstructorMessages < ActiveRecord::Migration
  def change
    add_reference :instructor_messages, :instructor_conversation, index: true
  end
end
