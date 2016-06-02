class Manage::ReportsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  respond_to :js , only: [:date_wise_jobs,:date_wise_started_jobs]
  before_action :check_user_permission, only: [ :index, :date_wise_jobs ,:detailed_view]

  def index
    session[:from] = ""
    session[:to] = ""
    to = Date.today
    from = to - 30
    @private_id = ClassType.find_by_title("Private")
    @group_id = ClassType.find_by_title("Group")
     if from == to
      @jobs = Job.where("DATE(DATE(created_at)) = ?", from).count
      @jobs_completed = Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt")
      @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt")
      @total_amount = [Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) = ? ", from).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
      @total_balance =  ManualPayment.where("payment_date = ?", from).sum(:balance)
    else
       @jobs = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to ).count  
       @jobs_completed = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt")
       @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt")
       @total_amount = [Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
       @total_balance =  ManualPayment.where("payment_date >= ? AND payment_date <= ?", from, to).sum(:balance)
    end  
     # @jobs = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to ).count
     # @jobs_completed = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt")
     @jobs_completed_total = @jobs_completed.count
     @jobs_fee_total = @jobs_completed.pluck(:fee_total).compact.inject(0,:+)
     @jobs_refered_total = @jobs_completed.pluck(:referral).compact.inject(0,:+)
     @jobs_start_date_total = @jobs_start_date.count
     @students = 0
     @jobs_start_date.each do |job|
      @students += job.students.count
     end
     @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
     @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
    @manual_payments = ManualPayment.where("payment_date >= ? AND payment_date <= ?", from, to)
    render layout: "setting_data"
  end

  def date_wise_jobs
    @private_id = ClassType.find_by_title("Private")
    @group_id = ClassType.find_by_title("Group")
    from = params[:from]
    to = params[:to]
    session[:from] = params[:from]
    session[:to] = params[:to]
    if from == to
      @jobs = Job.where("DATE(created_at) = ?", from).count
      @jobs_completed = Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt")
      @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt")
      @total_amount = [Job.where("DATE(created_at) = ?", from).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) = ? ", from).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
      @total_balance =  ManualPayment.where("payment_date = ?", from).sum(:balance)
    else
       @jobs = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to ).count  
       @jobs_completed = Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt")
       @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt")
       @total_amount = [Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @private_id.id.to_s).count, Job.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", from, to).where(:job_status => "Receipt").where(:class_type => @group_id.id.to_s).count]
       @total_balance =  ManualPayment.where("payment_date >= ? AND payment_date <= ?", from, to).sum(:balance)
    end  
   
    @jobs_completed_total = @jobs_completed.count
    @jobs_fee_total = @jobs_completed.pluck(:fee_total).compact.inject(0,:+)
    @jobs_refered_total = @jobs_completed.pluck(:referral).compact.inject(0,:+)
     @jobs_start_date_total = @jobs_start_date.count
     @students = 0
     @jobs_start_date.each do |job|
      @students += job.students.count
     end
     @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
     @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
    @manual_payments = ManualPayment.where("payment_date >= ? AND payment_date <= ?", from, to)
    render layout: 'setting_data'
  end
  
  def detailed_view
    to = Date.today
    from = to - 30
    if to == session[:to].to_date && from == session[:from].to_date || session[:to] == "" && session[:from] == ""
      if from == to
        @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt").order("start_date desc")
      else
        @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt").order("start_date desc")
      end 
      @students = 0
      @jobs_start_date.each do |job|
        @students += job.students.count
      end
      @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
      @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
    else
      from = session[:from]
      to = session[:to]
      if from == to
        @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt").order("start_date desc")
      else
         @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt").order("start_date desc")
      end  
      @students = 0
      @jobs_start_date.each do |job|
        @students += job.students.count
      end
      @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
      @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
    end  
  end
  def date_wise_started_jobs
    from = params[:from]
    to = params[:to]
    if from == to
      @jobs_start_date = Job.where("start_date = ?", from).where(:job_status => "Receipt").order("start_date desc")
    else
       @jobs_start_date = Job.where("start_date >= ? AND start_date <= ?", from, to).where(:job_status => "Receipt").order("start_date desc")
    end  
   
     @students = 0
     @jobs_start_date.each do |job|
      @students += job.students.count
     end
     @jobs_start_date_fee_total = @jobs_start_date.pluck(:fee_total).compact.inject(0,:+)
     @jobs_start_date_refered_total = @jobs_start_date.pluck(:referral).compact.inject(0,:+)
  end
  private
  def check_user_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      end
    else
      redirect_to manage_root_path
    end
  end
end