class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.references :instructor, index: true
      t.integer :points
      t.references :job, index: true

      t.timestamps
    end
  end
end
