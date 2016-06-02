class AddPrivateLessonVenueIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :private_lesson_venue_id, :integer
  end
end
