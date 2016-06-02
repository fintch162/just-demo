class ChangeDatatypeOfTimingFieldInInstructorStudentTimingFromStringToTime < ActiveRecord::Migration
  def change
  	change_column :instructor_student_timings, :time, 'time USING CAST(time AS time)'
  end
end
