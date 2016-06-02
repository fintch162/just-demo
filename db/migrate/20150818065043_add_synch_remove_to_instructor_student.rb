class AddSynchRemoveToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :synch_remove, :boolean, default: false
  end
end
