class RemoveColumnFeeTypeToGroupClass < ActiveRecord::Migration
  def change
  	remove_column :group_classes, :fee_type
  end
end
