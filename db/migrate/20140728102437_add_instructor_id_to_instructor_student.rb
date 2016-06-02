class AddInstructorIdToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :instructor_id, :integer
  end
end
