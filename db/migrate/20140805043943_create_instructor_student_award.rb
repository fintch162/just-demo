class CreateInstructorStudentAward < ActiveRecord::Migration
  def change
    create_table :instructor_student_awards do |t|
    	t.belongs_to :instructor_student
      t.belongs_to :award
      t.date :achieved_date
      t.timestamps
    end
  end
end
