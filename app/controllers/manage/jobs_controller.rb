class Manage::JobsController < Manage::BaseController
  # require 'paypal-sdk-merchant'
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  before_action :get_invoice_from_freshbook, only: [:confirm_job_invoice]
  respond_to :html, :json
  before_action :load_api_setting
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Jobs Listings", :manage_jobs_path
  before_action :check_user_permission, only: [ :index, :new, :create, :edit, :show, :update, :group_search_venue_age_group, 
                                                :confirm_job, :confirm_job_invoice, :send_message_as_mail, 
                                                :instructor_take_job ]

  
  def index
    # @jobs = policy_scope(Job).filter(params)
    # authorize @jobs
    @job_status = ["New", "Post", "Suggest", "Invoice", "Receipt", "Delete"]
    @jobs = Job.where(:job_status => "Post").count
    @jobs_invoice=Job.where(:job_status => "Invoice").count
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: JobsDatatable.new(view_context) }
    end
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    @job.students.each do |student|
      if student.age.present?
        if student.age > 6
          student.update_attributes(:age_month => "")
        end
      end
    end
    authorize @job
    if @job.save
      redirect_to manage_job_path(@job)
    else
      render json: {}, status:  422
    end
  end

  def edit
  end
  def show
    add_breadcrumb "Job Ref "+ @job.id.to_s, manage_job_path(@job.id)
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @job_status = ["New", "Post", "Suggest", "Invoice", "Receipt", "Delete"]
    @job_by_lead_contact = Job.where(:lead_contact=> @job.lead_contact) if @job.lead_contact.present?
    @venue = Venue.find_by_id(@job.venue_id).name if @job.venue_id?
    @class_level = Level.find(@job.class_level).title if @job.class_level?
    @class_type = ClassType.find(@job.class_type).title if @job.class_type?
    @age_group = AgeGroup.find(@job.age_group).title if @job.age_group?
    @list_students = []
    if !@job.invoices.blank? 
      @invoice = @job.invoices.last
      if !@invoice.invoice_time.blank?
        @invoice_time = @invoice.invoice_time
      end
    end
   
    @job.students.each do |student|
      arr_job_st = [student.name]
      if student.age?
        arr_job_st << [" - ", student.age, "yrs "]
      end
      if !student.age_month.blank? && student.age_month != 0 
        arr_job_st << [student.age_month, "mths"]
      else
        if student.age_month? && student.sex?
         arr_job_st << ["old"]
        end
      end  
      if student.sex?
        arr_job_st << [" (",student.sex, ")"]
      end
      if @job.students.last != student
        arr_job_st << ["<br>"]
      end
      @list_students << arr_job_st
    end
    begin
      @job_freshbook_invoices = []
      @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      if @job.invoices.count > 0
        @job.invoices.each do |inv|
          @freshbook_invoices = @freshbookconnection.invoice.get :invoice_id => inv.freshbooks_invoice_id
          @job_freshbook_invoices << @freshbook_invoices["invoice"]
        end
      end
    rescue Exception => e
      flash[:freshBookError] = "Invoice : " + e.to_s
    end
    @instructor = @job.instructor
    if !@instructor.nil?
      search_by_number = @instructor.mobile
      @instructor_messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{search_by_number}%").order("time_created DESC").paginate(:page => params[:page])
    else
      @instructor_messages = []
    end

    if !@job.lead_contact.nil?
      @customer_messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{@job.lead_contact}%").order("time_created DESC").paginate(:page => params[:page])
    else
      @customer_messages = []
    end
    @canned_responses = CannedResponse.all
    @payment_notifications = PaymentNotification.where(:job_ref => @job.id)
    @manual_job_payments = ManualPayment.where(job_id: @job.id).order("id")

    # exit
    # @freshbook_invoices = @freshbookconnection.invoice.list.to_json
    # logger.info "-------| #{@freshbook_invoices} |-------"
    # @freshbook_invoices =JSON.parse(@freshbook_invoices)["invoices"]
    # @total = @freshbook_invoices["total"].to_i
    # if @total == 1
    #   if @freshbook_invoices["invoice"]["po_number"].to_i == @job.id 
    #     @job_freshbook_invoices << @freshbook_invoices["invoice"]
    #   end
    # elsif @total > 1
    #   @freshbook_invoices["invoice"].each do |p| 
    #     if p["po_number"].to_i == @job.id
    #       @job_freshbook_invoices << p
    #     end
    #   end  
    # end
    @group_classes = []
    @instructors = []
    str = ''
    flag = 0
    if @job.venue_id && @job.venue_id != ''
      str = 'venue_id = ' + @job.venue_id.to_s
      flag = 1
    end
    if @job.age_group && @job.age_group != ''
      if flag == 1
        str += ' AND age_group_id = '+ @job.age_group.to_s
      else
        str += 'age_group_id = ' + @job.age_group.to_s
      end
    end
    if @job.venue_id
      @group_classes = GroupClass.where(str).order('day asc,time asc').where(is_deleted: false)
      @instructors = Instructor.where('id IN (?)',@group_classes.pluck('instructor_id').uniq)
    end
    params[:job_id] = @job.id
  end

  def instructor_load_more_message
    @job = Job.find(params[:job_id])
    @instructor = @job.instructor
    if !@instructor.nil?
      search_by_number = @instructor.mobile
      @instructor_messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{search_by_number}%").order("time_created DESC").paginate(:page => params[:page])
      @m = @instructor_messages.next_page
    else
      @instructor_messages = []
    end
  end

  def customer_load_more_message
    @job = Job.find(params[:job_id])
    if !@job.lead_contact.nil?
      @customer_messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{@job.lead_contact}%").order("time_created DESC").paginate(:page => params[:page])
    else
      @customer_messages = []
    end
  end

  def update
    if params[:save_inst_message] || params[:save_cust_message]
      @job.update_attributes(:message_to_instructor => params[:save_inst_message])
      @job.update_attributes(:message_to_customer => params[:save_cust_message])
    end
    
    @job.update(job_params)
    @job.students.each do |student|
      if student.age?
        if student.age > 6 
          student.update_attributes(:age_month => "")
        end  
      end  
    end
    @manual_payment = ManualPayment.where(job_id: @job.id)
    @manual_payment.update_all goggles_status: @job.goggles_status, job_status: @job.job_status
    respond_to do |format|
      format.js
      format.html do
        if @job.valid?
          redirect_to manage_job_path(@job), notice: "Job saved."
        else
          render "edit"
        end
      end
      format.json do
        if @venue.valid?
          render json: { status: 202 }
        else
          render json: {}, status:  422
        end
      end
    end
  end

  def group_search_venue_age_group
    venue = params[:venue]
    age_gp = AgeGroup.find_by(:title => params[:age_group])
    if age_gp.nil?
      @group_classes = CoordinatorClass.where(:venue_id => venue).order('day asc,time asc')
    else
      @group_classes = CoordinatorClass.where("venue_id  = ? and age_group_id = ?", venue, age_gp).order('day asc,time asc')
    end
  end

  def confirm_job
    @jobs = Job.where(:job_status => "Receipt").order('start_date asc')
    add_breadcrumb "Confirm Jobs", :manage_confirm_job_path
  end

  def confirm_job_invoice
    @m = params[:id]
    @job_freshbook_invoices = []
    
    @freshbook_invoices =JSON.parse(@freshbook_invoices)["invoices"]
    @total = @freshbook_invoices["total"].to_i
    if @total == 1
      if @freshbook_invoices["invoice"]["po_number"].to_i ==  @m.to_i 
        @job_freshbook_invoices << @freshbook_invoices["invoice"]
      end
    elsif @total > 1
      @freshbook_invoices["invoice"].each do |p| 
        if p["po_number"].to_i == @m.to_i
          @job_freshbook_invoices << p
        end
      end  
    end
    respond_to do |format|
      format.js
      format.html { render :layout => false }
    end
  end

  def send_message_as_mail
    message_content = params[:message_content]
    @job = Job.find_by_id(params[:job_id])
    begin
      timeout(50) do
        EmbedRegistration.send_message_as_email(message_content, @job).deliver
        respond_to do |format|
          format.js { render :text => 'Done' }
        end
      end
    rescue Timeout::Error, SocketError => e
      puts "....... \r\r #{e} \r\r ..........."
      render :text => e, status: 503
    end
  end
  
  def instructor_take_job
    @take_job = InstructorJobApplication.update_all(:coordinator_view => true)
    @take_job_count = InstructorJobApplication.where(:coordinator_view => false).count
    add_breadcrumb "Instructor take job", :manage_instructor_take_job_path
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: InstructorJobApplicationDatatable.new(view_context) }
    end
  end

  def sms_payment
  end

  def generate_pdf_job
    @job = Job.find_by_id(params[:job])

    lead_name = params[:lead_name]
    newAddress = params[:lead_address]
    quantity = params[:quantity]

    @job.update print_lead_name: lead_name, print_lead_address: newAddress, print_quantity: quantity
    redirect_to "#{request.protocol}#{request.host_with_port}/manage/#{@job.id}/print-details.pdf"
  end
  def print_details
    @job = Job.find_by_id(params[:job])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = JobPdf.new(@job, view_context)
        pdf.print
        send_data pdf.render, :disposition => 'inline', :type => 'application/pdf', :x_sendfile => true
      end
    end
  end

  def add_payment_status
    online_payment = PaymentNotification.find(params[:payment_notification_id])
    @job = Job.find(online_payment.job_ref)
    @manual_payment = ManualPayment.create(job_id: online_payment.job_ref, amount: online_payment.amount,referral: online_payment.amount ,payment_method: online_payment.paid_by, goggles_status: @job.goggles_status, job_status: @job.job_status, description: "", invoice_number: online_payment.invoice_id.to_s, committed: "false", payment_date: online_payment.created_at, manual_transaction_id: online_payment.transaction_id,local_payment_id: online_payment.id)
    # online_payment.update(status: "Added")
    redirect_to manage_job_path(params[:job_id])
  end

  def add_manual_payment
    @job = Job.find(params[:job_id])
    paymentDate = params[:date_payment]
    if @job
      if params[:balance] || params[:payment_method] || params[:start_date]
        @manual_payment = ManualPayment.new(job_id: @job.id, payment_date: params[:start_date],balance: params[:balance], amount: "", payment_method: params[:payment_method],
                                          goggles_status: @job.goggles_status, job_status: @job.job_status,
                                          description: "",
                                          invoice_number: @job.invoices.count == 1 ? @job.invoices.last.invoice_number : "",
                                          committed: "false")
        if @manual_payment.save
          redirect_to manage_job_path(@job)
        end
      else
        @manual_payment = ManualPayment.new(job_id: @job.id, amount: "", payment_method: "",
                                          goggles_status: @job.goggles_status, job_status: @job.job_status,
                                          description: "",
                                          invoice_number: @job.invoices.count == 1 ? @job.invoices.first.invoice_number : "",
                                          committed: "false", payment_date: paymentDate)
          if @manual_payment.save
            redirect_to manage_job_path(@job)
          end
      end
    end
  end

  def apply_group_class
    @group_class = GroupClass.find(params[:gc_id])
    @job = Job.unscoped.find(params[:id])
  end

  def send_feedback_sms
    @job=Job.find(params[:job_id])
    if @job.feedback_token
      @feedback_token = @job.feedback_token
    else
      @feedback_token = Array.new(5){rand(36).to_s(36)}.join
      @job.update_attributes(feedback_token: @feedback_token)
    end
  end

  private
    def set_job
      @job = Job.unscoped.find(params[:id])
      authorize @job
    end
    def load_api_setting
      @api_setting = ApiSetting.first
    end
    def job_params
      params.require(:job).permit(:applied_date, :group_class_id, :print_lead_name, :print_lead_address, :print_quantity, :private_lesson_venue_id, :allow_xfers, :bank_transfer , :enets,:allow_red_dot, :duration ,:request_full_payment, :allow_paypal, :lead_lady_instructor_only,:lead_affiliate ,:lead_class_type,:other_venue ,:private_lesson, :lead_condo_name, :lead_day_time, :lead_starting_on ,:post_date ,:instructor_id, :venue_id ,:preferred_time ,:referral ,:par_pax ,:fee_total ,:age_group ,:class_level ,:start_date ,:class_type ,:venue ,:lead_email ,:lead_contact ,:lead_name ,:day_of_week ,:customer_contact ,:customer_name ,:first_attendance ,:goggles_status ,:lock_date ,:message_to_instructor ,:job_status ,:message_to_customer ,:coordinator_notes ,:lead_info ,:lead_address ,:lesson_count ,:fee_type_id ,:class_time ,:completed_by ,:show_names ,:free_goggles ,:lady_instructor, venue_ids: [], terms_and_condition_ids: [] , :preferred_days_attributes => [:id, :job_id, :day,:preferred_time],:students_attributes => [ :id, :job_id, :name, :age, :age_month, :sex, :_destroy]) rescue {}
    end

    def get_invoice_from_freshbook
      load_api_setting
      @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      @freshbook_invoices = @freshbookconnection.invoice.list.to_json
    end
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