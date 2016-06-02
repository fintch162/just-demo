class AddAttachmentPhotoToInstructorStudentPhotos < ActiveRecord::Migration
  def self.up
    change_table :instructor_student_photos do |t|
      t.attachment :photo
    end
  end

  def self.down
    remove_attachment :instructor_student_photos, :photo
  end
end
