class AddAttachmentIdentityImageToInstructorIdentities < ActiveRecord::Migration
  def self.up
    change_table :instructor_identities do |t|
      t.attachment :identity_image
    end
  end

  def self.down
    remove_attachment :instructor_identities, :identity_image
  end
end
