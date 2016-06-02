class CreateRegistrationPackages < ActiveRecord::Migration
  def change
    create_table :registration_packages do |t|
      t.integer :no_of_student
      t.boolean :is_lady
      t.float   :price
      t.integer :age_group_id

      t.timestamps
    end
  end
end
