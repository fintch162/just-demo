class Instructor::FeePaymentNotificationsController < Instructor::BaseController
	
  before_action :check_user_permission, only: [:index]
  def index
    # if params[:id].present?
    #   @fee_payment_notifications = current_admin_user.fee_payment_notifications.where(id: params[:id]).includes(:fee => [:instructor_student])
    # else
    #   @fee_payment_notifications = current_admin_user.fee_payment_notifications.includes(:fee => [:instructor_student]).where(status: "Paid")
    # end
    respond_to do |format|
      format.html { }
      format.json { 
        render json: InstFeePaymentNotificationDatatable.new(view_context) 
      }
    end
    
    # instructor_fee_payment_notifications_path
  end
  def show
    @fee_payment_notifications = current_admin_user.fee_payment_notifications.where(id: params[:id]).includes(:fee => [:instructor_student])
  end

  def return_response_reddot_card
		@fee=Fee.find(params["order_number"].gsub('FEE',''))
		if !params["error_code"].present?

      if @fee.fee_payment_notifications.where(status: 'Paid').count == 0
			 @fee_pn = @fee.fee_payment_notifications.create(response_params: params,paid_by: 'Reddot Visa/Master',status: params["result"],transaction_id: params["transaction_id"],amount: params["amount"])
			 @fee_pn.update(merchant_reference: params[:merchant_reference])
      end
      # @fee.update(payment_date: Time.zone.now)
			# @fee.update(payment_status: 'Paid') if params["result"] == 'Paid'
      flash[:notice]='<strong>Success!</strong> Payment completed.'
      redirect_to payment_options_path(@fee.instructor_student.secret_token,@fee.id)
      # redirect_to student_public_link_path(@fee.instructor_student.secret_token)
    else
      @fee.fee_payment_notifications.create!(:response_params => params, :paid_by => "Reddot Visa/Master",:status => params["result"], :amount => params["amount"],merchant_reference: params["merchant_reference"])
      flash[:alert]='Payment failed. Please try again.'
      redirect_to payment_options_path(@fee.instructor_student.secret_token,@fee.id)
    end
	end

	def return_response_eNets
		@fee=Fee.find(params["order_number"].gsub('FEE',''))
    if !params["error_code"].present? && params["result"] != 'Rejected'
			if @fee.fee_payment_notifications.where(status: 'Paid').count == 0
        @fee_pn = @fee.fee_payment_notifications.create(response_params: params,paid_by: 'Reddot eNets',status: params["result"],transaction_id: params["transaction_id"],amount: params["amount"])
			 @fee_pn.update(merchant_reference: params[:merchant_reference])
      end
      # @fee.update(payment_date: Time.zone.now)
			# @fee.update(payment_status: 'Paid') if params["result"] == 'Paid'
      flash[:notice]='<strong>Success!</strong> Payment completed.'
      redirect_to payment_options_path(@fee.instructor_student.secret_token,@fee.id)
    else
      @fee.fee_payment_notifications.create!(:response_params => params, :paid_by => "Reddot eNets",:status => params["result"], :amount => params["amount"],merchant_reference: params["merchant_reference"])
      flash[:alert]='Payment failed. Please try again.'
      redirect_to payment_options_path(@fee.instructor_student.secret_token,@fee.id)
    end
	end

	def fee_red_dot_notification
    notification_response =  request.body.read
    response_status = ''
    transaction_id = ''
    amount = ''
    fee_id = ''
    merchant = ''
    notification_response = notification_response.split('&')
    
    notification_response.each do |n|
      if n.include?('result')
        m = n.split('=')
        response_status = m[1]
      elsif n.include?('transaction_id')
        t = n.split('=')
        transaction_id = t[1]
      elsif n.include?('amount')
        a = n.split('=')
        amount=a[1]
      elsif n.include?('merchant_reference')
        p = n.split('=')
        merchant = p[1]
      elsif n.include?('order_number')
        p = n.split('=')
        fee_id = p[1].gsub('FEE','')
        @fee = Fee.find(fee_id)
      end
    end

    @payment_notification  = FeePaymentNotification.find_by(transaction_id: transaction_id)
    if !@payment_notification.nil?
      mn = @payment_notification.update_attributes(:status => response_status)
			# @payment_notification.fee.update(payment_status: 'Paid') if response_status == 'Paid'
    else
      if @fee.fee_payment_notifications.where(status: 'Paid') == 0
        @fee_pn = @fee.fee_payment_notifications.create!(:response_params => notification_response, :paid_by => "Reddot Visa/Master", :transaction_id => transaction_id,:status => response_status, :amount =>amount,merchant_reference: merchant)
      end
			# @fee.update(payment_status: 'Paid') if response_status == 'Paid'
    end
    render :nothing => true
  end
  def check_payment_status
    if Fee.find(params[:id]).is_paid
      render :status => 400,
      :json => {}
    else
      render :status => 200,
      :json => {}
    end
  end

end