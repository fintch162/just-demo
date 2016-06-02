class Manage::JobFeedbacksController < Manage::BaseController
	include ApplicationHelper
  before_action :user_manage_permission
	add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Feedbacks", :manage_job_feedbacks_path

	def index
		@job_feedbacks = JobFeedback.order('created_at DESC')
		render layout: "setting_data"
	end

	def destroy
		@job_feedback = JobFeedback.find(params[:id])
		@job_feedback.destroy
		respond_to do |format|
			format.html{ redirect_to manage_job_feedbacks_path }
		end
	end

end