class AddFontSizeToMoreOrLessMonths < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :font_size, :integer
  end
end
