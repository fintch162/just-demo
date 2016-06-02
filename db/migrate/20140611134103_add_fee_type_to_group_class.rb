class AddFeeTypeToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :fee_type, :string
  end
end
