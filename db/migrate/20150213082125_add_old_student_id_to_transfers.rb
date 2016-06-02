class AddOldStudentIdToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :old_student_id, :integer
  end
end
