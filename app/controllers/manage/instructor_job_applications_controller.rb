class Manage::InstructorJobApplicationsController < Manage::BaseController
  # require 'paypal-sdk-merchant'
  include ApplicationHelper
  before_action :set_instructor_job_application, only: [:destroy]

  def destroy
  	@instructor_job_application.destroy
  	respond_to do |format|
      format.html {  redirect_to manage_instructor_take_job_path }
    end
  end

  private
   	def set_instructor_job_application
   		@instructor_job_application = InstructorJobApplication.find(params[:id])
   	end
end
