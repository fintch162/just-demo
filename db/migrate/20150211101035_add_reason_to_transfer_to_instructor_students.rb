class AddReasonToTransferToInstructorStudents < ActiveRecord::Migration
  def change
    add_column :instructor_students, :reason_to_transfer, :text
  end
end
