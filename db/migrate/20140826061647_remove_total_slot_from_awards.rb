class RemoveTotalSlotFromAwards < ActiveRecord::Migration
  def change
    remove_column :awards, :total_slot, :integer
  end
end
