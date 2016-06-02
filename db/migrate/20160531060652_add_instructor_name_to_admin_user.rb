class AddInstructorNameToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :instructor_name, :string
  end
end
