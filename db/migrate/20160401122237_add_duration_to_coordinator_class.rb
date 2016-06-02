class AddDurationToCoordinatorClass < ActiveRecord::Migration
  def change
    add_column :coordinator_classes, :duration, :integer
  end
end
