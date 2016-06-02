class AddReferralAndBalanceToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :referral, :integer
    add_column :manual_payments, :balance, :integer
  end
end
