class AddInstructorIdToMoreOrLessMonths < ActiveRecord::Migration
  def change
    add_column :more_or_less_months, :instructor_id, :integer
  end
end
