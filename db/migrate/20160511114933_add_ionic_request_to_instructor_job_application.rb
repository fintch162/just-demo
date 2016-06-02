class AddIonicRequestToInstructorJobApplication < ActiveRecord::Migration
  def change
    add_column :instructor_job_applications, :ionic_request, :string
  end
end
