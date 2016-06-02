class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :phone_number
      t.string :contact_id

      t.timestamps
    end
  end
end
