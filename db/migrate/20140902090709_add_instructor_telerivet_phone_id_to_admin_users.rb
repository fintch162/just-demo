class AddInstructorTelerivetPhoneIdToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :instructor_telerivet_phone_id, :string
  end
end
