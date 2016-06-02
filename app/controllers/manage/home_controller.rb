class Manage::HomeController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission, except: [:index]

  add_breadcrumb "Home", :manage_root_path
  respond_to :js, only: [ :get_dashboard_data_filter ]  
  
  def index
    session[:from] = ""
    session[:to] = ""
  	@jobs_refered = Job.where(job_status: "Receipt" ,:created_at =>  Date.today.beginning_of_day..Date.today.end_of_day)
    @jobs_refered_total = Job.where(job_status: "Receipt",:created_at => Date.today.beginning_of_day..Date.today.end_of_day).pluck(:referral)
    @today_jobs = Job.where(:created_at =>  Date.today.beginning_of_day..Date.today.end_of_day)

    @sms_count = 0
    if !current_admin_user.nil? && !current_admin_user.coordinator?
      user_manage_permission
    elsif !current_admin_user.nil?
      @sms_count = current_admin_user.messages.where("LOWER(direction) IN (?)", ['outgoing']).where(:created_at => Date.today.beginning_of_day..Date.today.end_of_day).count
    end

    # Chart Value
    # @private_id = ClassType.find_by_title("Private")
    # @group_id = ClassType.find_by_title("Group")

    # @jobs = Job.count
    # @jobs_completed = Job.where(:job_status => "Receipt")
    # @jobs_start_date = Job.where(:job_status => "Receipt")
    # @total_amount = [Job.where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
    # @jobs_completed_total = @jobs_completed.count
    # @jobs_fee_total = @jobs_completed.pluck(:fee_total).compact.inject(0,:+)
    # @jobs_refered_total = @jobs_completed.pluck(:referral).compact.inject(0,:+)
    # @jobs_start_date_total = @jobs_start_date.count
    # @students = 0
    # @jobs_start_date.each do |job|
    #   # @students += job.students.count
    # end
    # @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
    # @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
  end
  def api_list
    @api_settings = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
  end

  def update_api
    api_key = params[:apikey]
    project_id = params[:projectId]
    phone_id = params[:phoneId]
    webhook_api = params[:webhookApi]
    begin
      tr = Telerivet::API.new(api_key)
      project = tr.init_project_by_id(project_id)
      phone = project.get_phone_by_id(phone_id)
      telerivet_phone_number = phone.phone_number
      @api_settings = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
      if @api_settings.blank?
        CoordinatorApiSetting.create(coordinator_id: current_admin_user.id,telerivet_api_key: api_key,telerivet_project_id: project_id, telerivet_phone_id: phone_id, :webhook_api_secret => webhook_api, :telerivet_phone_number => telerivet_phone_number )
        current_admin_user.update_attributes(:is_account_activated => true)
      else
        @api_settings.update(telerivet_api_key: api_key,telerivet_project_id: project_id, telerivet_phone_id: phone_id, :webhook_api_secret => webhook_api, :telerivet_phone_number => telerivet_phone_number )
        current_admin_user.update_attributes(:is_account_activated => true)
      end
      redirect_to manage_setting_path, :notice => "Your account has been activated."
    rescue Exception => e
      redirect_to manage_setting_path, :notice => "#{e}"
    end
  end

  def get_dashboard_data_filter
    start_date = params[:startDate]
    end_date = params[:endDate]
    session[:from] = start_date
    session[:to] = end_date
    @total_enquires = Job.where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
    @jobs_refered = Job.where(job_status: "Receipt").where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
    @jobs_refered_total = Job.where(job_status: "Receipt").where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day).pluck(:referral)
    @today_jobs = Job.where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
    @sms_count = 0
    if !current_admin_user.nil?
      @sms_count = current_admin_user.messages.where("LOWER(direction) IN (?)", ['outgoing']).where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day).count
    end
    # Chart Value
    # from = start_date
    # to = end_date
    # @private_id = ClassType.find_by_title("Private")
    # @group_id = ClassType.find_by_title("Group")
    # if from == to
    #   @jobs = Job.where("DATE(created_at) = ?", from).count
    #   @jobs_completed = Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt")
    #   @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt")
    #   @total_amount = [Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) = ? ", from).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
    # else
    #   @jobs = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to ).count  
    #   @jobs_completed = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt")
    #   @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt")
    #   @total_amount = [Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
    # end  
   
    # @jobs_completed_total = @jobs_completed.count
    # @jobs_fee_total = @jobs_completed.pluck(:fee_total).compact.inject(0,:+)
    # @jobs_refered_total = @jobs_completed.pluck(:referral).compact.inject(0,:+)
    #  @jobs_start_date_total = @jobs_start_date.count
    #  @students = 0
    #  @jobs_start_date.each do |job|
    #   @students += job.students.count
    #  end
    #  @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
    #  @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
  end

  private
  # def check_user_permission
  #   logger.info"<-----------------#{current_admin_user.inspect}-------------------------->"
  #   if admin_user_signed_in?
  #     if current_admin_user.instructor?
  #       redirect_to instructor_root_path
  #     elsif current_admin_user.admin?
  #       redirect_to admin_root_path
  #     elsif current_admin_user.accountant?
  #       redirect_to accountant_root_path
  #     end
  #   end
  # end
end