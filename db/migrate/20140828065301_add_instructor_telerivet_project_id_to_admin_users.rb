class AddInstructorTelerivetProjectIdToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :instructor_telerivet_project_id, :string
  end
end
