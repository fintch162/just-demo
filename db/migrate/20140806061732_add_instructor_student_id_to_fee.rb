class AddInstructorStudentIdToFee < ActiveRecord::Migration
  def change
    add_column :fees, :instructor_student_id, :integer
  end
end
