class AddAttachmentProfilePictureToInstructorStudents < ActiveRecord::Migration
  def self.up
    change_table :instructor_students do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    remove_attachment :instructor_students, :profile_picture
  end
end
