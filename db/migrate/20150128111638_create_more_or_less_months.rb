class CreateMoreOrLessMonths < ActiveRecord::Migration
  def change
    create_table :more_or_less_months do |t|
      t.string :table_name
      t.string :start_month
      t.string :end_month

      t.timestamps
    end
  end
end
