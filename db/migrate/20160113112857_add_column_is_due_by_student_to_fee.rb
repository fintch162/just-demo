class AddColumnIsDueByStudentToFee < ActiveRecord::Migration
  def change
    add_column :fees, :is_due_by_student, :boolean, default: false
  end
end
