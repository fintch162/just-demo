class AddIsDeletedToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :is_deleted, :boolean
  end
end
