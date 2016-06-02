class RemoveFeeAttendanceFromMoreOrLessMonths < ActiveRecord::Migration
  def change
    remove_column :more_or_less_months, :fee_attendance, :string
  end
end
