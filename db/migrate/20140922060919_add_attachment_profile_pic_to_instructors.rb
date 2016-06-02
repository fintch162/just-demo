class AddAttachmentProfilePicToInstructors < ActiveRecord::Migration
  def self.up
    change_table :instructors do |t|
      t.attachment :profile_pic
    end
  end

  def self.down
    remove_attachment :instructors, :profile_pic
  end
end
