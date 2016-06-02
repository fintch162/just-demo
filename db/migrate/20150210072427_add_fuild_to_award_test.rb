class AddFuildToAwardTest < ActiveRecord::Migration
  def change
  	add_column :award_tests, :cut_off_date, :date
  end
end
