class RemoveFeeTypeIdTojobs < ActiveRecord::Migration
  def change
  	remove_column :jobs, :fee_type_id
  end
end
