class AddTotalSlotToAwardTests < ActiveRecord::Migration
  def change
    add_column :award_tests, :total_slot, :integer
  end
end
