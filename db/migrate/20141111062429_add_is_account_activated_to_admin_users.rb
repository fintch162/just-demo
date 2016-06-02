class AddIsAccountActivatedToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :is_account_activated, :boolean
  end
end
