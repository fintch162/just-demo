class AddColumnBankIdToManualPayment < ActiveRecord::Migration
  def change
    add_column :manual_payments, :bank_id, :integer
  end
end
