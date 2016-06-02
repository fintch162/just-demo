class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.date :payment_date
      t.string :course_type
      t.string :monthly_detail
      t.integer :amount
      t.date :course_detail

      t.timestamps
    end
  end
end
