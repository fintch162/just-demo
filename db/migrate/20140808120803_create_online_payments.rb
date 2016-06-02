class CreateOnlinePayments < ActiveRecord::Migration
  def change
    create_table :online_payments do |t|
      t.integer :job_id
      t.integer :invoice_id
      t.string :unique_identifier

      t.timestamps
    end
  end
end
