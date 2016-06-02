class AddVenueToHideShowColumns < ActiveRecord::Migration
  def change
    add_column :hide_show_columns, :venue, :boolean, default: true
  end
end
