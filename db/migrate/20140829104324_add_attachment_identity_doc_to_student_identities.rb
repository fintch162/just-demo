class AddAttachmentIdentityDocToStudentIdentities < ActiveRecord::Migration
  def self.up
    change_table :student_identities do |t|
      t.attachment :identity_doc
    end
  end

  def self.down
    remove_attachment :student_identities, :identity_doc
  end
end
