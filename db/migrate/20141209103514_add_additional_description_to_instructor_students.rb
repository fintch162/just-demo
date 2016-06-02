class AddAdditionalDescriptionToInstructorStudents < ActiveRecord::Migration
  def change
    add_column :instructor_students, :additional_description, :text
  end
end
