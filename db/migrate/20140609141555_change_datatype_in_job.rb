class ChangeDatatypeInJob < ActiveRecord::Migration
  def change
  	change_column :jobs, :preferred_time, :text
  end
end
