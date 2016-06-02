class AddTotalSlotToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :total_slot, :integer
  end
end
