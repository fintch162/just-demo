class AddShortNameFieldToTiming < ActiveRecord::Migration
  def change
    add_column :timings, :short_name, :string
  end
end
