class AddamountToCoordinatorClasses < ActiveRecord::Migration
  def change
  	add_column :coordinator_classes, :amount, :float
  end
end
