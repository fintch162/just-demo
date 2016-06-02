class AddDueDateToFee < ActiveRecord::Migration
  def change
    add_column :fees, :due_date, :date
  end
end
