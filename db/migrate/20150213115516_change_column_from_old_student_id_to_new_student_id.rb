class ChangeColumnFromOldStudentIdToNewStudentId < ActiveRecord::Migration
  def change
    rename_column :transfers, :old_student_id, :new_student_id
  end
end
