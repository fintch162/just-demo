class AddPositionToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :position, :integer
  end
end
