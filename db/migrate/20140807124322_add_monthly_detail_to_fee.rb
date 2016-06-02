class AddMonthlyDetailToFee < ActiveRecord::Migration
  def change
    add_column :fees, :monthly_detail, :date
  end
end
