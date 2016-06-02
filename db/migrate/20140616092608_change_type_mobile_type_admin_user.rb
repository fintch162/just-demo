class ChangeTypeMobileTypeAdminUser < ActiveRecord::Migration
  def change
    change_column :admin_users, :mobile, :string
  end
end
