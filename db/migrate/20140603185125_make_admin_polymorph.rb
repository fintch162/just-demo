class MakeAdminPolymorph < ActiveRecord::Migration
  def change
    add_column :admin_users, :type, :string
    add_index :admin_users, :type

    execute "update admin_users set type='SuperAdmin' where true"
  end
end
