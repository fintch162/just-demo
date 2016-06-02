class AddHightligtTrainingToMoreOrLessMonth < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :highlight_training, :boolean, :default => false
    add_column :more_or_less_months, :training_cell_month, :integer
  end
end
