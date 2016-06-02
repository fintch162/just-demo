class AddPastGroupClassIdsToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :past_group_class_ids, :integer,array: true,default: []
  end
end
