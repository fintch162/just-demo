class AddStudentViewUrlToApiSettings < ActiveRecord::Migration
  def change
    add_column :api_settings, :student_view_url, :string
  end
end
