class ChangeColumnTypeForTime < ActiveRecord::Migration
  def change
    change_column :group_classes, :time, :time
  end
end
