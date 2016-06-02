class AddIsRegisteredToInstructorStudents < ActiveRecord::Migration
  def change
    add_column :instructor_students, :is_registered, :boolean
  end
end
