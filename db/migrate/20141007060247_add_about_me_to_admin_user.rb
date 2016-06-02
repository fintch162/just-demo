class AddAboutMeToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :about_me, :text
  end
end
