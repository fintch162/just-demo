class AddColumnBankIdToOnlinePayment < ActiveRecord::Migration
  def change
    add_column :online_payments, :bank_id, :integer
  end
end
