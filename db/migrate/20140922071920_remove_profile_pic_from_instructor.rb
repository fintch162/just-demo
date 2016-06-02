class RemoveProfilePicFromInstructor < ActiveRecord::Migration
  def change
  	remove_column :instructors, :profile_pic_file_name
  	remove_column :instructors, :profile_pic_content_type
  	remove_column :instructors, :profile_pic_file_size
  	remove_column :instructors, :profile_pic_updated_at
  end
end