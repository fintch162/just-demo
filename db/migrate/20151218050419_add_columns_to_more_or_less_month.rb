class AddColumnsToMoreOrLessMonth < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :start_month_view_atte, :date
    add_column :more_or_less_months, :end_month_view_atte, :date
  end
end
