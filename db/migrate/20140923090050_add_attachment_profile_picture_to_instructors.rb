class AddAttachmentProfilePictureToInstructors < ActiveRecord::Migration
  def self.up
    change_table :instructors do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    remove_attachment :instructors, :profile_picture
  end
end
