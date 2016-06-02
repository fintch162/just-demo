class CreateStudentGroupClassHistories < ActiveRecord::Migration
  def change
    create_table :student_group_class_histories do |t|
      t.references :instructor_student, index: true
      t.references :group_class, index: true

      t.timestamps
    end
  end
end
