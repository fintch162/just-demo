class CreateInstructorStudentTimings < ActiveRecord::Migration
  def change
    create_table :instructor_student_timings do |t|
      t.references :instructor_student, index: true
      t.references :timing, index: true
      t.string :time
      t.date :date

      t.timestamps
    end
  end
end
