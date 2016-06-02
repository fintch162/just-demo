class AddAwardTestIdToInstructorStudentAwards < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :award_test_id, :integer
  end
end
