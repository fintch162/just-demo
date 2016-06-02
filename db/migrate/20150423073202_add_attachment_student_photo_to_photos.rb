class AddAttachmentStudentPhotoToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.attachment :student_photo
    end
  end

  def self.down
    remove_attachment :photos, :student_photo
  end
end
