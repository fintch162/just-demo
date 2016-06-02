class AddColumnFeeTypeIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :fee_type_id, :integer
  end
end
