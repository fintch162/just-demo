class ChangeNameOfMessageToNum < ActiveRecord::Migration
  def change
    rename_column :messages, :to_nubmer, :to_number
  end
end
