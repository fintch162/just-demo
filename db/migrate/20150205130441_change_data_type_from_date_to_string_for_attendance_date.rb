class ChangeDataTypeFromDateToStringForAttendanceDate < ActiveRecord::Migration
  def change
  	change_column :student_attendances, :attendance_date, :string
  end
end
