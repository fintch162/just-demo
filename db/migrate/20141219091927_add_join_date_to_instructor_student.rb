class AddJoinDateToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :join_date, :date
  end
end
