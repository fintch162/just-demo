class AddStatusToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :status, :string
  end
end
