class Manage::GenerateFormsController <  Manage::BaseController
	include ApplicationHelper
  before_action :user_manage_permission
	add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Generate Form", :manage_swimming_lessons_registration_generator_path
	def generator
    @job = Job.new
    @job.students.build
    5.times { @job.preferred_days.build}
    @venues = Venue.where(['name not in (?)', ["Buona Vista Swimming Complex","Bukit Timah Swimming Complex","Kallang Basin Swimming Complex", "Condo"]])
  end
end
  