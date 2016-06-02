class ChangeColumnTypeForJobDayOfWeek < ActiveRecord::Migration
  def change
    change_column :jobs, :day_of_week, :string
  end
end
