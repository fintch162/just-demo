class CreateInstructorIdentities < ActiveRecord::Migration
  def change
    create_table :instructor_identities do |t|
      t.integer :instructor_id
      t.integer :identity_card_id
      t.date :expiry_date

      t.timestamps
    end
  end
end
