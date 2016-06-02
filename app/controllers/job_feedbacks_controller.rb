class JobFeedbacksController < ApplicationController
	def new
		@job = Job.find_by(feedback_token: params[:id])
		@job_feedback = @job.job_feedback.new
	end

	def create
		@feedback = JobFeedback.new(job_feedback_params)
		if @feedback.save
			@job = Job.find(job_feedback_params[:job_id])
			flash[:notice] = 'Feedback sent!'
			redirect_to feedback_path(@job.feedback_token) 
		else
			render 'new'
		end
	end

	private
		def job_feedback_params
    	params.require(:job_feedback).permit(:reasons,:other_feedback,:job_id,:rates) rescue {}
  	end 
end
