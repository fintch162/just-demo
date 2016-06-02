class AddColumnFeeTypeIdToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :fee_type_id, :integer
  end
end
