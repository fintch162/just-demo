class AddAwardProgressToInstructorStudentAwards < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :award_progress, :string
  end
end
