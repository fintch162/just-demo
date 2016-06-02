class CreateManualPayments < ActiveRecord::Migration
  def change
    create_table :manual_payments do |t|
      t.integer :job_id
      t.integer :amount
      t.string :payment_method
      t.string :goggles_status

      t.timestamps
    end
  end
end
