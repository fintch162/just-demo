class CreateGroupClasses < ActiveRecord::Migration
  def change
    create_table :group_classes do |t|
      t.integer :day
      t.time :time
      t.string :level
      t.integer :duration
      t.references :venue, index: true
      t.references :instructor, index: true
      t.timestamps
    end
  end
end
