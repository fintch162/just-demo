class AddShowAmountToMoreOrLessMonth < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :show_amount, :boolean
  end
end
