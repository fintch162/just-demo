class Manage::OnlinePaymentsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :check_user_permission, only: [ :index ]
  respond_to :js, only: [ :make_payment_for_invoice ]
  before_action :load_api_setting, only: [ :make_payment_for_invoice ]
  add_breadcrumb "Home", :manage_root_path
  
  def index

    add_breadcrumb "Transactions", manage_online_payments_path
  
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: OnlinePaymentsDatatable.new(view_context) 
      }
    end
  end
  def make_payment_for_invoice
    @online_payment_id = params[:online_payment].to_i
    @online_payment = PaymentNotification.find_by_id(params[:online_payment].to_i)
    if @online_payment.invoice_id != "" || !@online_payment.invoice_id.nil?
      @invoice = @online_payment.invoice_id 
      payment_date = @online_payment.created_at.strftime("%Y-%m-%d").to_date
      amount = @online_payment.amount
      payment_method = @online_payment.paid_by


      if @online_payment.paid_by != "Paypal"
        payment_method = "Bank Transfer"
      end
      @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      @freshbook_payment = @freshbookconnection.payment.create(:payment => { :invoice_id => @invoice, :amount => amount, :date => payment_date, :type=> payment_method })
    end
    @online_payment.update(:status => "Added")
    # puts "...........#{@freshbook_payment.inspect}"

  end
  def show
    @payment_notification = PaymentNotification.find(params[:id])
  end

  def destroy
    @payment_notification = PaymentNotification.find(params[:id])
    @payment_notification.destroy
    redirect_to manage_online_payments_path
  end

  def edit
    @payment_notification = PaymentNotification.find(params[:id])
  end
  def update_notification
    @payment_notification = PaymentNotification.find(params[:payment_notification][:id])
    @m = @payment_notification.update(:job_ref => params[:payment_notification][:job_ref], :paid_by => params[:payment_notification][:paid_by], :amount => params[:payment_notification][:amount], :payment_date => params[:payment_notification][:payment_date], :status => params[:payment_notification][:status], :pay_time => params[:payment_notification][:pay_time])
    if @m == true
      redirect_to manage_online_payment_path(@payment_notification)
    else
      redirect_to edit_manage_online_payment_path(@payment_notification)
    end
  end

  def new
    @payment_notification = PaymentNotification.new
  end

  def create_notification
    logger.info "<---------#{params}-------->"
    @payment_notification = PaymentNotification.create(:job_ref => params[:payment_notification][:job_ref], :paid_by => params[:payment_notification][:paid_by], :amount => params[:payment_notification][:amount], :payment_date => params[:payment_notification][:payment_date], :status => params[:payment_notification][:status], :pay_time => params[:payment_notification][:pay_time])
    if !@payment_notification.nil?
      redirect_to manage_online_payments_path
    else
      redirect_to new_manage_online_payment_path
    end
  end

  def save_online_payments_to_manual_payments
    begin
    online_payment = PaymentNotification.find(params[:payment_id])
    @job = Job.find(online_payment.job_ref)
    @manual_payment = ManualPayment.create(job_id: online_payment.job_ref, amount: online_payment.amount, payment_method: online_payment.paid_by,
                                          goggles_status: @job.goggles_status, job_status: @job.job_status, 
                                          description: "", invoice_number: online_payment.invoice_id.to_s, committed: "false", payment_date: online_payment.created_at,manual_transaction_id: online_payment.transaction_id, local_payment_id: online_payment.id)
    
    # online_payment.update(status: "Added")
      redirect_to manage_online_payments_path
    rescue Exception => e
      redirect_to manage_online_payments_path
    end
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
    def load_api_setting
      @api_setting = ApiSetting.first
    end
end