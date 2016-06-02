class AddTimingFieldToHideShowColumns < ActiveRecord::Migration
  def change
    add_column :hide_show_columns, :timing, :text
  end
end
