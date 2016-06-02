class CreateStudentAttendances < ActiveRecord::Migration
  def change
    create_table :student_attendances do |t|
      t.date :attendance_date
      t.integer :group_class_id
      t.integer :instructor_student_id
      t.string :attendance_status

      t.timestamps
    end
  end
end
