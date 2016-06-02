class RemoveIsDueByStudentFromFee < ActiveRecord::Migration
  def change
    remove_column :fees, :is_due_by_student, :boolean
  end
end
