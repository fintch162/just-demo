class AddColumnToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :daily_backup_on, :boolean, default: false
  end
end
