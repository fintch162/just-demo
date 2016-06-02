class AddContactsPrefixToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :contacts_prefix, :string
  end
end
