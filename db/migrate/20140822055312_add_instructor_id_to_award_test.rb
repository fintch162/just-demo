class AddInstructorIdToAwardTest < ActiveRecord::Migration
  def change
    add_column :award_tests, :instructor_id, :integer
  end
end
