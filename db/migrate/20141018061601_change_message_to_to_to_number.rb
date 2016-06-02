class ChangeMessageToToToNumber < ActiveRecord::Migration
  def change
    rename_column :messages, :to, :to_number
  end
end
