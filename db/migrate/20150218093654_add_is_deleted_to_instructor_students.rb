class AddIsDeletedToInstructorStudents < ActiveRecord::Migration
  def change
    add_column :instructor_students, :is_deleted, :boolean, default: false
  end
end
