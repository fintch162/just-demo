class CreateInstructorStudents < ActiveRecord::Migration
  def change
    create_table :instructor_students do |t|
      t.string :student_name
      t.integer :age
      t.string :gender
      t.string :contact
      t.boolean :job_id
      t.date :date_of_birth

      t.timestamps
    end
  end
end
