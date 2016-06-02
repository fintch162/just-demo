class CreateInstructors < ActiveRecord::Migration
  def change
    create_table :instructors do |t|
      t.string :name
      t.integer :mobile

      t.timestamps
    end
  end
end
