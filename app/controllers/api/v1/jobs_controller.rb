class Api::V1::JobsController < ApplicationController
  include WelcomeHelper
  before_action :check_authentication_token 
  skip_before_filter :verify_authenticity_token, only: [ :change_job_status ]

	def index
		fetch_job('post','Post')
    manipulate_template
	end

  def change_job_status
    @takeJobDesc = params[:job_desc] != 'null' ? params[:job_desc] : ''
    @findJob = InstructorJobApplication.find_by(instructor_id: params[:instId],job_id: params[:id])
    if @findJob
      if @findJob.ionic_request == 'Take'
        @findJob.update_attributes(ionic_request: 'Cancel')
      else
        @findJob.update_attributes(ionic_request: 'Take')
      end
    else
      @findJob = InstructorJobApplication.create(instructor_id: params[:instId],job_id: params[:id],ionic_request: 'Take',applied: true, description: @takeJobDesc)
    end
    logger.info"---------#{@findJob}-------------------#{@findJob.inspect}----------------------"
    render json: @findJob
  end

  def job_receipt
    fetch_job('receipt','Receipt')
    manipulate_template
  end

  def fetch_job(msgStatus,jobStatus)
    @instructor_template_body = ''
    @message_templete = MessageTemplate.find_by_job_status(msgStatus)
    if @message_templete.has_instructor
      @instructor_template_body = jobStatus != 'Receipt' ? @message_templete.app_posting_template : @message_templete.app_receipt_template 
    end
    jobStatus != 'Receipt' ? @jobs = Job.where(job_status: jobStatus).order("updated_at DESC") : @jobs = Job.where(job_status: jobStatus, instructor_id: @user.id).order("start_date DESC").paginate(:page => params[:offset], :per_page => 20)
  end

  def manipulate_template
    logger.info"------------#{@instructor_template_body}--------------------"
    @job_with_template = []
    @jobs.each do |job|
      @template = convert_job_template(@instructor_template_body,job,@user) 
      @job_with_template << {job: job, template: @template , class_type: @class_type, venue: @venue_name, student_count: @job_Student,job_application: @job_application}
    end
    render json: @job_with_template
  end
end


 
