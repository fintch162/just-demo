class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :instructor_id
      t.integer :transfer_to
      t.integer :instructor_student_id
      t.text :reason
      t.string :transfer_status

      t.timestamps
    end
  end
end
