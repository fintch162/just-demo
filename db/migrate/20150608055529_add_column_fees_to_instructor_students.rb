class AddColumnFeesToInstructorStudents < ActiveRecord::Migration
  def change
    add_column :instructor_students, :fee, :integer
  end
end
