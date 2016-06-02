class AddPaymentModeToFees < ActiveRecord::Migration
  def change
    add_column :fees, :payment_mode, :string
  end
end
