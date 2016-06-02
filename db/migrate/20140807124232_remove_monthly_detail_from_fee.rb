class RemoveMonthlyDetailFromFee < ActiveRecord::Migration
  def change
    remove_column :fees, :monthly_detail, :string
  end
end
