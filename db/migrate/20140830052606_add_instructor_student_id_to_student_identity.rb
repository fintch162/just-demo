class AddInstructorStudentIdToStudentIdentity < ActiveRecord::Migration
  def change
    add_column :student_identities, :instructor_student_id, :integer
  end
end
