class RemoveOldLevelFromClasses < ActiveRecord::Migration
  def change
    remove_column :group_classes, :level
  end
end
