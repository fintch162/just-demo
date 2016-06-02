class RenameColumnFromRemoveSynchToIsUpdate < ActiveRecord::Migration
  def change
  	rename_column :instructor_students, :synch_remove, :is_update
  end
end
