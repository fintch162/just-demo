class AddFeeAttendanceFromMoreOrLessMonths < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :fee_attendance, :string, :default => 'no'
  end
end
