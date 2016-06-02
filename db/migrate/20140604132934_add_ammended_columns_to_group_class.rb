class AddAmmendedColumnsToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :age_group_id, :integer
    add_column :group_classes, :class_type_id, :integer
    add_column :group_classes, :fee, :integer, default: 0
    add_column :group_classes, :lesson_count, :integer, default: 0
    add_column :group_classes, :remarks, :string
    add_column :group_classes, :level_id, :integer
  end
end
