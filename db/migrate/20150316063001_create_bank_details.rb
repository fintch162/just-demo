class CreateBankDetails < ActiveRecord::Migration
  def change
    create_table :bank_details do |t|
      t.string :bank_name
      t.column :account_number, :bigint
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
