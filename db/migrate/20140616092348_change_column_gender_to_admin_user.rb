class ChangeColumnGenderToAdminUser < ActiveRecord::Migration
  def change
    change_column :admin_users, :gender, :string
  end
end
