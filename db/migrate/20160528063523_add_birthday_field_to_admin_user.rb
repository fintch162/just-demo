class AddBirthdayFieldToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :birthday, :datetime
  end
end
