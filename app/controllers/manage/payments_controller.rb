class Manage::PaymentsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
	before_action :set_payment, only: [:show, :edit, :update, :destroy]
  before_action :load_api_setting
  respond_to :html, :json

  def index
  	@payment = Payment.all
  end

  def new
    @payment = Payment.new
  end

  def create
    # @payment = Payment.new(payment_params)
  	# if @payment.save
     payment_date = params[:payment][:payment_date].to_date.strftime("%Y-%m-%d").to_date
  
      @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      # @invoice = Invoice.find_by_id(@payment.invoice_id)
      @freshbook_payment = @freshbookconnection.payment.create(:payment => {:invoice_id =>  params[:payment][:invoice_id], :amount => params[:payment][:amount], :date => payment_date,:type=> params[:payment][:method_type],:notes => params[:payment][:note]})
      # @payment.update_attributes(:freshbooks_payment_id => @freshbook_payment["payment_id"])
      @job = Invoice.find_by(:freshbooks_invoice_id => params[:payment][:invoice_id]).job
  		
      render :text => 0
  	# else
  	#render json: @payment.errors, status:  422
  	# end
  end


  private
    def set_payment
      @payment = Payment.unscoped.find(params[:id])
      authorize @job
    end

    def load_api_setting
      @api_setting = ApiSetting.first
    end

    def payment_params
      params.require(:payment).permit(:invoice_id, :freshbooks_payment_id, :amount, :note, :method_type, :payment_date) 
    end
end