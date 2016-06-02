class AddAdminUserIdToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :admin_user_id, :integer
  end
end
