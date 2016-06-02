class AddGoogleContactIdToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :google_contact_id, :string
  end
end
