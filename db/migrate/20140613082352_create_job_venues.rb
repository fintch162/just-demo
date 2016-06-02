class CreateJobVenues < ActiveRecord::Migration
  def change
    create_table :job_venues do |t|
      t.belongs_to :job
      t.belongs_to :venue
      t.timestamps
    end
  end
end
