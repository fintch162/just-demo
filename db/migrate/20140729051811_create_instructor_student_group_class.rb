class CreateInstructorStudentGroupClass < ActiveRecord::Migration
  def change
    create_table :instructor_student_group_classes do |t|
    	t.belongs_to :instructor_student
      t.belongs_to :group_class
      t.timestamps
    end
  end
end
