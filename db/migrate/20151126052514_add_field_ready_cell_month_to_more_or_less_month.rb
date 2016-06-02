class AddFieldReadyCellMonthToMoreOrLessMonth < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :ready_cell_month, :integer
  end
end
