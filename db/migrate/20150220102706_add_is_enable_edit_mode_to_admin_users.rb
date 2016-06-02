class AddIsEnableEditModeToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :is_enable_edit, :boolean
  end
end
