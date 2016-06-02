class RenameColumnNameFromMonth1ProfilePic < ActiveRecord::Migration
  def change
  	rename_column :hide_show_columns, :month1, :profile_pic
  end
end
