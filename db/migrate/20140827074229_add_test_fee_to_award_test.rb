class AddTestFeeToAwardTest < ActiveRecord::Migration
  def change
    add_column :award_tests, :test_fee, :decimal
  end
end
