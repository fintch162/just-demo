class AddGenderAndShortNameToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :gender, :boolean
    add_column :admin_users, :short_name, :string
  end
end
