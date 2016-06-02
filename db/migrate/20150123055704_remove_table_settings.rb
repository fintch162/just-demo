class RemoveTableSettings < ActiveRecord::Migration
  def change
  	drop_table :table_settings
  end
end
