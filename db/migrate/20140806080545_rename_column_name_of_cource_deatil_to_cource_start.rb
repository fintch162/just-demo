class RenameColumnNameOfCourceDeatilToCourceStart < ActiveRecord::Migration
 def change
    rename_column :fees, :course_detail, :course_start
  end
end
