class AddAttendanceToStudentAttendance < ActiveRecord::Migration
  def change
    add_column :student_attendances, :attendance, :date
  end
end
