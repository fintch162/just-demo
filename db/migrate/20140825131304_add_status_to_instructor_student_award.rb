class AddStatusToInstructorStudentAward < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :status, :string
  end
end
