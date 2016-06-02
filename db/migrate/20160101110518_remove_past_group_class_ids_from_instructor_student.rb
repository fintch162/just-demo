class RemovePastGroupClassIdsFromInstructorStudent < ActiveRecord::Migration
  def change
    remove_column :instructor_students, :past_group_class_ids, :integer
  end
end
