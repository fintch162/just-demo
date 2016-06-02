class AddProfilePicToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :profile_pic, :binary
  end
end
