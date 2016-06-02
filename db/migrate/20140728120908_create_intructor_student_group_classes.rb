class CreateIntructorStudentGroupClasses < ActiveRecord::Migration
  def change
    create_table :intructor_student_group_classes do |t|
    	t.belongs_to :instructor_student, index: true
    	t.belongs_to :group_class, index: true

      t.timestamps
    end
  end
end
