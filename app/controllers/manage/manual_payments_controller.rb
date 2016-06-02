class Manage::ManualPaymentsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_manual_payment, only: [:edit, :update, :destroy, :show]
  before_action :load_api_setting, only: [:add_payment, :remove_payment]
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Manual Payments", :manage_manual_payments_path
  respond_to :js, only: :manual_payments_filter
 


  def index
    if !session[:job_id].nil?
      session.delete(:job_id)
    end
    @manual_payment = ManualPayment.new
    if params[:payment_desc] == "Referral"
      @manual_payments = ManualPayment.where('description LIKE ?', 'Referral').order('position')
    elsif params[:payment_desc] == "Balance"
      @manual_payments = ManualPayment.where('description LIKE ?', 'Balance').order('position')
    else
      # @manual_payments = ManualPayment.order('position')
      # @referral_manual_payments = ManualPayment.where(:payment_date => Time.zone.now.strftime("%Y-%m-%d")).where('description LIKE ?', 'Referral').order('position')
      # @balance_manual_payments = ManualPayment.where(:payment_date => Time.zone.now.strftime("%Y-%m-%d")).where('description LIKE ?', 'Balance').order('position')
      @manual_payments = ManualPayment.where(:payment_date => Time.zone.now.strftime("%Y-%m-%d")).order('position')
    end
  end

  def new
    @manual_payment = ManualPayment.new
  end

  def show
  end

  def create
    @totalCount = ManualPayment.where(:payment_date => params[:payment_date].to_date.strftime("%Y-%m-%d")).order('position').count
    paymentDate = params[:payment_date]
    begin
      @job = Job.find(manual_payment_params[:job_id])
    rescue Exception => e
      @job_not_found = e
    end
    if @job
      @manual_payment = ManualPayment.new(job_id: @job.id, amount: "", payment_method: "",
                                          goggles_status: @job.goggles_status, job_status: @job.job_status,
                                          description: "",
                                          invoice_number: @job.invoices.count == 1 ? @job.invoices.first.invoice_number : "",
                                          committed: "false", payment_date: paymentDate)
      if @manual_payment.save
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def edit
    add_breadcrumb @manual_payment.id.to_s
    job = Job.find(@manual_payment.job_id)
    @invoices = job.invoices
  end

  def update
    if manual_payment_params[:referral] == "0"
      @manual_payment.update referral: nil
    elsif manual_payment_params["balance"] == "0"
      @manual_payment.update balance: nil
    else
      @manual_payment.update(manual_payment_params)
    end
    allManualPaymentGogglesStatus = ManualPayment.where(job_id: @manual_payment.job_id)
    allManualPaymentGogglesStatus.update_all goggles_status: @manual_payment.goggles_status
    job = Job.find(@manual_payment.job_id)
    job.update goggles_status: @manual_payment.goggles_status
    referralAmt = @manual_payment.referral.nil? ? 0 : @manual_payment.referral
    balanceAmt = @manual_payment.balance.nil? ? 0 : @manual_payment.balance
    totalAmount = referralAmt + balanceAmt
    @manual_payment.update amount: totalAmount

    if params[:in_place_editing] == "false"
      redirect_to manage_manual_payments_path
    else  
      render :json => @manual_payment
    end
  end

  def destroy
    @manual_payment.destroy
    redirect_to manage_manual_payments_path
  end

  def find_manual_payment_by_date 
    @manual_payment = ManualPayment.new
    selectedDate = params[:selectedDate].to_date.strftime("%Y-%m-%d")
    if params[:payment_desc].present?
      if params[:payment_desc] == "All"
        @manual_payments = ManualPayment.where(:payment_date => selectedDate).order('position')
      else
        @manual_payments = ManualPayment.where(:payment_date => selectedDate).where('description LIKE ?', params[:payment_desc]).order('position')
      end
    else
      @manual_payments = ManualPayment.where(:payment_date => selectedDate).order('position')
    end

    respond_to do |format|
      format.js
    end
  end

  def manual_payments_filter
    if params[:paymentDate].present?
      selectedDate = params[:paymentDate]
    else
      selectedDate = Time.zone.now.strftime("%Y-%m-%d")
    end
    if params[:payment_desc] == "All"
      @manual_payments = ManualPayment.where(:payment_date => selectedDate).order('position')
    else
      @manual_payments = ManualPayment.where(:payment_date => selectedDate).where('description LIKE ?', params[:payment_desc]).order('position')
    end
  end
 
  def sort
    @manual_payments = ManualPayment.all
    params[:manual_payment].each_with_index do |id, index|
      @manual_payments.where(:id => id).each do |p|
        p.update position: index+1
      end
    end
    render nothing: true
  end

  def add_payment
    @manual_payment = ManualPayment.find(params[:id])
    if @manual_payment.amount.to_i == 0 
      amount =  @manual_payment.balance.to_i + @manual_payment.referral.to_i
      @manual_payment.update(amount: amount)   
    end
    if !@manual_payment.amount.nil?
      # exit
      if @manual_payment.invoice_number.present? && @manual_payment.amount > 0
        begin
          @invoice_id = Invoice.find_by_invoice_number(@manual_payment.invoice_number)
          @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
          @freshbook_payment = @freshbookconnection.invoice.get(:invoice_id =>  @invoice_id.freshbooks_invoice_id)
          out_standing_amount = @freshbook_payment["invoice"]["amount_outstanding"]
          if @manual_payment.amount.to_i > out_standing_amount.to_i
            @error = "Commit fail as amount due is less than the amount you are committing."
            @m = false
          else  
            @freshbook_payment = @freshbookconnection.payment.create(:payment => {
                                                                                    :invoice_id =>  @invoice_id.freshbooks_invoice_id,
                                                                                    :amount => @manual_payment.amount,
                                                                                    :date => @manual_payment.payment_date,
                                                                                    :type => @manual_payment.payment_method,
                                                                                    :notes => @manual_payment.description
                                                                                  }
                                                                    )
            if @freshbook_payment["error"]
              @error = @freshbook_payment["error"].gsub("_", " ")
              @m = false
            else
              @m = @manual_payment.update(committed: true, payment_id: @freshbook_payment["payment_id"])
            end
          end
        rescue Exception => e
          @error = "Invoice can not be generated due to some error!"  
          @m = false
        end
      else
        @error = "Invoice no or amount can't be blank."
        @m = false
      end
    else
      @error = "Invoice no or amount can't be blank."
      @m = false
    end 
  end

  def remove_payment
    begin
      @manual_payment = ManualPayment.find(params[:id])
      if @manual_payment.payment_id.blank?
        @error = "Payment not found on freshbook!"
        @m = false
      else
        @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
        @freshbook_payment = @freshbookconnection.payment.delete(:payment_id =>  @manual_payment.payment_id )
        if @freshbook_payment["error"].present?
          @error = @freshbook_payment["error"]
          @m = false
        else
          @m = @manual_payment.update(committed: false, payment_id: @manual_payment.local_payment_id)
        end
      end
    rescue Exception => e
      @error = "Invoice can not be generated due to some error!"
      @m = false
    end  
  end

  def uncommitted_payments
    add_breadcrumb "Uncommitted Payments", :manage_uncommitted_manual_payments_path
    @manual_payment = ManualPayment.new
    logger.info"<------new----#{@manual_payment.inspect}------->"
    @manual_payments = ManualPayment.where(committed: false).order('position')
    logger.info"<------pmnts----#{@manual_payments.inspect}------->"
    if params[:selectedDate].present?
      logger.info"<------if date----#{params[:selectedDate]}------->"
      selectedDate = params[:selectedDate].to_date.strftime("%Y-%m-%d")
      @manual_payments = @manual_payments.where(:payment_date => selectedDate)
    end
    respond_to do |format|
      format.js {}
      format.html{}
    end
  end

  private
    def set_manual_payment
      @manual_payment = ManualPayment.find(params[:id])
    end
    def manual_payment_params
      params.require(:manual_payment).permit(:job_id, :amount, :payment_method, :goggles_status, :job_status,
                                             :description, :invoice_number, :committed, :payment_date, :position, :is_payment_added,:balance, :referral, :payment_id,:manual_transaction_id,:local_payment_id)
    end
    def load_api_setting
      @api_setting = ApiSetting.first
    end
end