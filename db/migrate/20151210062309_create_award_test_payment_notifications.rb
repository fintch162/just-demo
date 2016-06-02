class CreateAwardTestPaymentNotifications < ActiveRecord::Migration
  def change
    create_table :award_test_payment_notifications do |t|
      t.text :response_params
      t.string :status
      t.string :transaction_id
      t.string :paid_by
      t.string :amount
      t.string :merchant_reference
      t.references :award_test, index: true
      t.references :instructor_student, index: true

      t.timestamps
    end
  end
end
