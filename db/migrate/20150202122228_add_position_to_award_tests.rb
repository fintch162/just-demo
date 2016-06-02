class AddPositionToAwardTests < ActiveRecord::Migration
  def change
  	 add_column :award_tests, :position, :integer
  end
end
