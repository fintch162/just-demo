class AddGroupIdToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :group_id, :integer
  end
end
