class AddAttachmentCompanyLogoToAdminUsers < ActiveRecord::Migration
  def self.up
    change_table :admin_users do |t|
      t.attachment :company_logo
    end
  end

  def self.down
    remove_attachment :admin_users, :company_logo
  end
end
