class AddTimeToCoordinatorClass < ActiveRecord::Migration
  def change
    add_column :coordinator_classes, :time, :time
  end
end
