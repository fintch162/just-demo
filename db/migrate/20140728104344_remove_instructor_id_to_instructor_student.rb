class RemoveInstructorIdToInstructorStudent < ActiveRecord::Migration
  def change
  	remove_column :instructor_students, :instructor_id
  end
end
