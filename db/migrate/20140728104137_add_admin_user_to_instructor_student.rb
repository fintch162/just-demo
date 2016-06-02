class AddAdminUserToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :admin_user_id, :integer
  end
end
