class RenameColumnFeeStructureToJob < ActiveRecord::Migration
  def change
    rename_column :jobs, :fee_structure, :fee_type_id
  end
end
