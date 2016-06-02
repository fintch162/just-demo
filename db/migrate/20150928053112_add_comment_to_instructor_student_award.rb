class AddCommentToInstructorStudentAward < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :comment, :text
  end
end
