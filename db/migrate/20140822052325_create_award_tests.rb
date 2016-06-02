class CreateAwardTests < ActiveRecord::Migration
  def change
    create_table :award_tests do |t|
      t.date :test_date
      t.time :test_time
      t.integer :award_id
      t.integer :venue_id
      t.integer :assessor

      t.timestamps
    end
  end
end
