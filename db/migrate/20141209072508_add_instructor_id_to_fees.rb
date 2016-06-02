class AddInstructorIdToFees < ActiveRecord::Migration
  def change
    add_column :fees, :instructor_id, :integer
  end
end
