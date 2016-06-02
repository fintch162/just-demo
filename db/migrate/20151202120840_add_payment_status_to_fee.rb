class AddPaymentStatusToFee < ActiveRecord::Migration
  def change
    add_column :fees, :payment_status, :string
  end
end
