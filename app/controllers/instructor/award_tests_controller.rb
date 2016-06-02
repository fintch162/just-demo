class Instructor::AwardTestsController < Instructor::BaseController
  before_action :set_award_test, only: [:show, :edit, :update, :destroy, :paid_remove_popup, :make_payment_in_cash]
  before_action :check_user_permission, only: [ :show, :update, :edit, :destroy] 

  def index

    # @past_award_tests = AwardTest.past_award_tests.order("test_date desc , test_time")
    # @comming_award_tests = AwardTest.comming_award_tests.order("test_date desc , test_time")
    @ins_student_id = current_admin_user.instructor_students.pluck(:id)
    @student_list_of_ready_for = InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress LIKE (?)", @ins_student_id, 'ready_for' )
    m = @student_list_of_ready_for.pluck('award_test_id')
    str = ""
    cnt = 0
    if params[:my_student].present? && params[:my_student] == "true"
      @award_tests = AwardTest.where("id IN (?)", m ).order("test_date desc , test_time")
    else
      @award_tests = AwardTest.order("test_date desc , test_time")
    end
    if params[:from]
      field_list = ["test_date", 'award_id', 'venue_id', 'assessor']
      if params[:from].present? || params[:to].present?
        if params[:to].present? && params[:to] != ''
          start_date = params[:from].to_date
          end_date = params[:to].to_date
          @award_tests = @award_tests.where(test_date:  start_date..end_date)
        else
          start_date = params[:from].to_date
          @award_tests = @award_tests.where("test_date >= ?", start_date)
        end
      end
      logger.info "<---#{params[:award]}--------->"
      if params[:award].present? && params[:award] != "" 
        str += field_list[1] + " = " + "'"+params[:award]+"'"
        logger.info "<---#{str}----------->"
        cnt =1
      end
      if params[:venue].present? && params[:venue] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[2] + " = " + "'"+params[:venue]+"'"
      end
      if params[:organiser].present? && params[:organiser] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[3] + " = " + "'"+params[:organiser]+"'"
      end 
      logger.info "<-----------#{str}-------------->"
      if !str.empty?
        @award_tests = @award_tests.where(str)
        award_id = @award_tests.pluck(:award_id)
        @test_id = @award_tests.pluck(:id)
        @award = Award.all#where("id IN (?)", award_id)
        @date = params[:from]
      else
        award_id = @award_tests.pluck(:award_id)
        @test_id = @award_tests.pluck(:id)   
        @award = Award.all#where("id IN (?)", award_id)
        @date = Date.today.strftime('%d %B %Y')
      end
    else
      start_date = Date.today
      @award_tests = AwardTest.where("test_date >= ?", start_date).order("test_date desc , test_time")
      @test_id = @award_tests.pluck(:id)
      award_id = @award_tests.pluck(:award_id)
      @award = Award.all#where("id IN (?)", award_id)
    end
  end

  def new
    @award_test = current_admin_user.award_tests.new
  end

  def create
    @award_test =  current_admin_user.award_tests.new(award_test_params)
    if @award_test.save
      respond_to do |format|
        format.html { redirect_to instructor_award_tests_path}
      end
    end
  end

  def edit
  end

  def update
    @award_test.update(award_test_params)
    respond_to do |format|
      format.html { redirect_to instructor_award_test_path(@award_test)}
    end
  end

  def show
    items = ["Pending", "pending", "Confirmed", "Pass", "Fail"]
    @instructor_student_award = @award_test.instructor_student_awards.where("status IN (?)",items)
  end

  def destroy
    @award_test.destroy
    respond_to do |format|
       format.html {  redirect_to instructor_award_tests_path }
    end
  end 

  def paid_remove_popup
    # award_test_paid_remove_popup_instructor_award_test_path
    @status = params[:status]
    @student_award = InstructorStudentAward.find(params[:student_award_id])
    respond_to :js
  end

  def make_payment_in_cash
    # award_test_cash_payment_instructor_award_test_path
    @award_test.award_test_payment_notifications.create(response_params: params,paid_by: 'Cash',status: 'Paid',amount: @award_test.test_fee,instructor_student_id: params[:student_id])
    redirect_to instructor_award_test_path(@award_test)
  end

  def remove_student
    @id=params[:id]
    InstructorStudentAward.find(params[:student_id]).update_attributes(:award_test_id => nil, :is_registered => false, :award_progress => "ready_for")
    redirect_to instructor_award_test_path(@id)
  end

  # payment for award-test
  def return_response_reddot_card
    # @award_test=AwardTest.find(params["order_number"].gsub('AT',''))
    @award_test=InstructorStudentAward.find(params["order_number"].gsub('AT','')).award_test
    @student = InstructorStudent.find(params["merchant_reference"])
    if !params["error_code"].present?
      if @award_test.award_test_payment_notifications.where(status: 'Paid').count >= 0
        @award_test.award_test_payment_notifications.create(response_params: params,paid_by: 'Reddot Visa/Master',status: params["result"],transaction_id: params["transaction_id"],amount: params["amount"],merchant_reference: params[:merchant_reference],instructor_student_id: @student.id)
      end
      flash[:notice]='<strong>Success!</strong> Payment completed.'
      # redirect_to student_public_link_path(@student.secret_token)
      redirect_to award_test_payment_options_path(@student.secret_token,@award_test.id)
    else
     @award_test.award_test_payment_notifications.create!(:response_params => params, :paid_by => "Reddot Visa/Master",:status => params["result"], :amount => params["amount"],merchant_reference: params["merchant_reference"],instructor_student_id: @student.id)
      flash[:alert]='Payment failed. Please try again.'
      redirect_to award_test_payment_options_path(@student.secret_token,@award_test.id)
    end
  end

  def return_response_eNets
    # @award_test=AwardTest.find(params["order_number"].gsub('AT',''))
    @award_test=InstructorStudentAward.find(params["order_number"].gsub('AT','')).award_test
    @student = InstructorStudent.find(params["merchant_reference"])
    if !params["error_code"].present? && params["result"] != 'Rejected'
      if @award_test.award_test_payment_notifications.where(status: 'Paid').count >= 0
        @award_test.award_test_payment_notifications.create(response_params: params,paid_by: 'Reddot eNets',status: params["result"],transaction_id: params["transaction_id"],amount: params["amount"],merchant_reference: params[:merchant_reference],instructor_student_id: @student.id)
      end
      flash[:notice]='<strong>Success!</strong> Payment completed.'
      redirect_to award_test_payment_options_path(@student.secret_token,@award_test.id)
      # redirect_to student_public_link_path(@student.secret_token)
    else
      @award_test.award_test_payment_notifications.create!(:response_params => params, :paid_by => "Reddot eNets",:status => params["result"], :amount => params["amount"],merchant_reference: params["merchant_reference"],instructor_student_id: @student.id)
      flash[:alert]='Payment failed. Please try again.'
      redirect_to award_test_payment_options_path(@student.secret_token,@award_test.id)
    end
    # instructor_return_response_reddot_eNets_award_test
  end

  def award_test_red_dot_notification
    logger.info"--------------#{params}--------------#{params[:order_number]}-------#{params["order_number"]}------"
    notification_response =  request.body.read
    response_status = ''
    transaction_id = ''
    amount = ''
    award_test_id = ''
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
        award_test_id = p[1].gsub('AT','')
        # @award_test = AwardTest.find(award_test_id)
        @award_test = InstructorStudentAward.find(params["order_number"].gsub('AT','')).award_test
      end
    end

    @payment_notification  = AwardTestPaymentNotification.find_by(transaction_id: transaction_id)
    if !@payment_notification.nil?
      mn = @payment_notification.update_attributes(:status => response_status)
    else
      if @award_test.award_test_payment_notifications.where(status: 'Paid').count == 0
        @award_test_payment_notification = @award_test.award_test_payment_notifications.create!(:response_params => notification_response, :paid_by => "Reddot Visa/Master", :transaction_id => transaction_id,:status => response_status, :amount =>amount,merchant_reference: merchant,instructor_student_id: merchant)
        @fee.update(payment_status: 'Paid') if response_status == 'Paid'
      end
    end
    render :nothing => true
  end
 
  private
  def set_award_test
    @award_test = AwardTest.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def award_test_params
    params.require(:award_test).permit(:test_date,:test_time,:award_id,:venue_id,:assessor, :admin_user_id)
  end

end
