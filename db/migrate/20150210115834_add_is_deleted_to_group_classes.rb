class AddIsDeletedToGroupClasses < ActiveRecord::Migration
  def change
    add_column :group_classes, :is_deleted, :boolean, default: false
  end
end
