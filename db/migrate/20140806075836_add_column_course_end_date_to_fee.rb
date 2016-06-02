class AddColumnCourseEndDateToFee < ActiveRecord::Migration
  def change
    add_column :fees, :course_end, :date
  end
end
