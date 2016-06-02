class AddStartMonthAtteAndEndMonthAtteToMoreOrLessMonths < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :start_month_atte, :string
    add_column :more_or_less_months, :end_month_atte, :string
  end
end
