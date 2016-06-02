class AddAgeMonthToStudents < ActiveRecord::Migration
  def change
    add_column :students, :age_month, :integer
  end
end
