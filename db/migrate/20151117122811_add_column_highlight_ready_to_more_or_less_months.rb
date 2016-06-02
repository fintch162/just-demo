class AddColumnHighlightReadyToMoreOrLessMonths < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :highlight_ready, :boolean,default: false
  end
end
