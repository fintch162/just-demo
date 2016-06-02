class AddLastActivityToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :last_activity, :datetime
  end
end
