class CreateCoordinatorClasses < ActiveRecord::Migration
  def change
    create_table :coordinator_classes do |t|
      t.integer :day
      t.references :venue, index: true
      t.references :instructor, index: true
      t.references :age_group, index: true
      t.references :coordinator, index: true

      t.timestamps
    end
  end
end
