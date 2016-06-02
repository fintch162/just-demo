class AddFeeTypeAndNotesToCoordinatorClasses < ActiveRecord::Migration
  def change
    add_column :coordinator_classes, :notes, :text
    add_reference :coordinator_classes, :fee_type, index: true
  end
end
