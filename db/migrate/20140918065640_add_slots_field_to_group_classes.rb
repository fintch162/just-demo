class AddSlotsFieldToGroupClasses < ActiveRecord::Migration
  def change
    add_column :group_classes, :slot_vacancy, :integer
    add_column :group_classes, :slot_maximum, :integer
  end
end
