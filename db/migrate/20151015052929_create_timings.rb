class CreateTimings < ActiveRecord::Migration
  def change
    create_table :timings do |t|
      t.string :title

      t.timestamps
    end
  end
end
