class CreateInstructorStudentPhotos < ActiveRecord::Migration
  def change
    create_table :instructor_student_photos do |t|
      t.references :instructor, index: true

      t.timestamps
    end
  end
end
