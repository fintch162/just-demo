class AddPostionToInstructorStudentAwards < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :position, :integer
  end
end
