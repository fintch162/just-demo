class CreatePreferredDays < ActiveRecord::Migration
  def change
    create_table :preferred_days do |t|
      t.integer :day
      t.integer :job_id
      t.time :preferred_time

      t.timestamps
    end
  end
end
