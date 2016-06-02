class AddPrivateLessonToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :private_lesson, :boolean
  end
end
