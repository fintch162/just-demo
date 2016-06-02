class AddPositionToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :position, :integer
  end
end
