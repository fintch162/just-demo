class RemoveClassTypeColumnFromGroupClass < ActiveRecord::Migration
  def change
    remove_column :group_classes, :class_type_id
  end
end
