class AddStudentIdToHideShowColumn < ActiveRecord::Migration
  def change
    add_column :hide_show_columns, :student_id, :boolean, default: false
  end
end
