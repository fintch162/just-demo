class AddAttachmentProfilePictureToAdminUsers < ActiveRecord::Migration
  def self.up
    change_table :admin_users do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    remove_attachment :admin_users, :profile_picture
  end
end
