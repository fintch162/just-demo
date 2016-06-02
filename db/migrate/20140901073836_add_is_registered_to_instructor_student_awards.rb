class AddIsRegisteredToInstructorStudentAwards < ActiveRecord::Migration
  def change
    add_column :instructor_student_awards, :is_registered, :boolean, default: false
  end
end
