class AddCoordinatorViewToInstructorJobApplication < ActiveRecord::Migration
  def change
    add_column :instructor_job_applications, :coordinator_view, :boolean, default:false
  end
end
