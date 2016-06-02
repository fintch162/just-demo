class AddGroupIdToInstructorMessage < ActiveRecord::Migration
  def change
    add_reference :instructor_messages, :group_class, index: true
  end
end
