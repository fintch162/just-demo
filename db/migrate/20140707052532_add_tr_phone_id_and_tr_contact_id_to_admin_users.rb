class AddTrPhoneIdAndTrContactIdToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :tr_phone_id, :string
    add_column :admin_users, :tr_contact_id, :string
  end
end