class WelcomeController < ApplicationController
  layout 'success_payment', :only => :success
  include WelcomeHelper
  # layout 'lightning_risk', :only => :global_lightning_risk
  
  before_action :get_invoice, :only => [:view_pa,:bank_transferred]
  before_action :set_instructor_student, :only => [:student_public_link, :edit_student, :test_registration, :student_public_gallery]

  def index
  end

  def bank_transferred
    @job = Job.find(params[:id])
    @bank_id = params[:bank_id].split("-")[0]
    @bank_name = params[:bank_id].split("-")[1]
    @bank_transferred = PaymentNotification.create(job_ref: @job.id,invoice_id: params[:invoice_id],amount: params[:amount],bank_id: @bank_id,status: "Completed",paid_by: @bank_name ,payment_date: Date.today ,pay_time: Time.current ,bank_id: @bank_id)    
    respond_to do |format|
      format.js
    end 
  end

  def view_pa
    @invoiceTimer =  @invoice.invoice_time ? (@invoice.invoice_time - Time.zone.now) : 0
    @api_setting = ApiSetting.first
    @job = Job.find(params[:id])
    @xfers_key = ApiSetting.first.xfers_key
    if @invoice != ""
      freshbooks_invoice_id = @invoice.freshbooks_invoice_id
      @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      logger.info"<====cn===#{@freshbookconnection.inspect}==============>"
      @invoice_freshbook = @freshbookconnection.invoice.get(:invoice_id => freshbooks_invoice_id)
      @payment_notification = PaymentNotification.where(invoice_id: @invoice.invoice_number, job_ref: @job.id).where('status IN (?)',['Paid','Completed']).last    
      logger.info"------#{@invoice_freshbook.inspect}--------------#{@payment_notification.inspect}---------------"
      #@payment_notification = PaymentNotification.where("invoice_id = ? AND job_ref = ?",  @invoice.invoice_number,  @job.id)
      if !@payment_notification.blank?
        @is_payment_done = @payment_notification.status
        #1 because we wont change status to added on add_payment_status so i set it manualy from here
          @manual_payment = ManualPayment.find_by_local_payment_id(@payment_notification.id.to_s)
          if @manual_payment.present?
            @manual_payment.committed ? @is_payment_done = 'Added' : ''
          end
        #1 
      else
        @is_payment_done = 'Added'
      end
    end
    # if @invoice_freshbook["invoice"]["status"] == 'paid' || @invoice_freshbook["invoice"]["status"] == 'Paid'
    if !@payment_notification.blank? || @job.job_status == "Receipt"
      @message_template = MessageTemplate.find_by_job_status("payment_advise").receipt_note
      @message_template_decode = convert_job_template(@message_template,@job,current_admin_user)
      @invoiceTimer = 0
    else
      @message_template = MessageTemplate.find_by_job_status("payment_advise").payment_advise_body
      @message_template_decode = convert_job_template(@message_template,@job,current_admin_user)
    end
    @manual_job_payments = ManualPayment.where(job_id: @job.id)
    
    @amount = 0
    @manual_job_payments.each do |m|
      if m.committed
        if m.referral.present?
          @amount = @amount + m.referral
        end
        if m.balance.present?
          @amount = @amount + m.balance
        end
      end
    end
    @manual_job_payments.each do |m|
      if m.committed
        @is_committed = m.committed  
      else
        @is_committed = m.committed
        break
      end
    end
    respond_to do |format|
      format.js
      format.html { render :layout => "online_payment" }
    end
  end

  def student_public_link

    if @instructor_student.gallery.nil?
      @gallery = Gallery.create(instructor_student_id: @instructor_student.id) 
    else
      @gallery = @instructor_student.gallery
    end
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    # @instructor_student = InstructorStudent.find_by_secret_token(params[:secret_token])
    award = params[:isAppliedFor]
    award_test = params[:awardTest]
    @instructor_student_award = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for", :is_registered => false)
    status = [ "Confirmed","pending", "Pending","confirmed", "fail", "Fail", "Pass", "pass", nil ]
    not_pass = [ "Confirmed","pending", "Pending","confirmed", "fail", "Fail"]
    @student_award_registered = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for", :is_registered => true).where.not(:status => "Pass")
    items = ["training_for", "ready_for"]
    @ready_award = @instructor_student.instructor_student_awards.where(:award_progress => "ready_for").where(:status => nil)
    @ready_award = @ready_award + @instructor_student.instructor_student_awards.where(:award_progress => "ready_for").where("status IN (?)", not_pass)

    @trainning_award = @instructor_student.instructor_student_awards.where(:award_progress => "training_for").where.not(:status => "Pass")
    @trainning_award += @instructor_student.instructor_student_awards.where(:award_progress => "training_for").where(:status => nil)

    @achieved_award = @instructor_student.instructor_student_awards.where("status IN (?)", ["pass", "Pass"])
    @achieved_award = @achieved_award + @instructor_student.instructor_student_awards.where(:award_progress => "achieved")
    # cut_off_date = params[:cut_off_date]
  end

  def student_public_gallery
  end

  def test_registration
    @instructor_student_award = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for")
    @group_classes = @instructor_student.group_classes
    @award = Award.find_by_name(params[:awardName])
  end

  def edit_student
    @group_classes = @instructor_student.group_classes.all
    @day_list = @group_classes.pluck(:day).uniq
  end

  def update_student
    @instructor_student = InstructorStudent.find(params[:instructor_student][:id])
    @instructor_student.update(instructor_student_params)
    respond_to do |format|
      format.html { redirect_to student_public_link_path(@instructor_student.secret_token)}
    end
  end

  def success
    id = params[:id]
    unique_inovice_number = params[:u_sec_number]
    amount = params[:amount]
    payment_method = ""
    if params[:payment_method]
      payment_method = params[:payment_method]
    else
      payment_method = "xfers"
    end
    customer_email = params[:customer]
    # @record_exist = OnlinePayment.find_by_unique_identifier(unique_inovice_number)
    # if !@record_exist
      # @invoice_payment_details = OnlinePayment.create(:job_id => id, :invoice_id => @invoice.id, :unique_identifier => unique_inovice_number, :amount => amount, :payment_method => payment_method, :customer_email => customer_email)
    # end
  end

  def cancel
    # logger.info "<----#{params}-------->"
    # exit
    @instructor_student_cancel = InstructorStudentAward.find(params[:instructor_student_award_id])
    @instructor_student_cancel.update(:award_test_id => nil, :is_registered => false, status: nil, award_progress: 'ready_for')
    @instructor_student_id = @instructor_student_cancel.instructor_student_id
    @instructor_student = InstructorStudent.find(@instructor_student_cancel.instructor_student_id).secret_token
    redirect_to student_public_link_path(@instructor_student)  
  end

  def booking_schedule
  end

  def booking_schedule_search
    str = ''
    spliter = ''
    if params[:venue].present?
      str = 'venue_id =' + params[:venue]
      spliter = 'AND '
    end
    if params[:age_group].present?
      str += spliter + 'age_group_id = '+params[:age_group]
    end
    @group_classes = GroupClass.where(str).where('booking_status IS NOT NULL')
  end

  def view_payment_option_student
    @instructor_student = InstructorStudent.find_by_secret_token(params[:secret_token])
    # @student_contact=@instructor_student.student_contacts.find_by(:primary_contact =>true) if @instructor_student.student_contacts
    @fee = Fee.find(params[:id])
    flash[:alert] = "Payment is already done." if @fee.is_paid && params[:from_pub_profile].present?
  end

  def current_month_fee
    logger.info"<--------------#{params}------------------------>"
    @instructor_student = InstructorStudent.find_by_secret_token(params[:secret_token])
    @inst_group_class=@instructor_student.group_classes.first
    @fee_type=FeeType.find(@inst_group_class.fee_type_id).name
    @amout=@instructor_student.fee ? @instructor_student.fee : @inst_group_class.fee
    logger.info"<---------#{@instructor_student.chek_monthly_fee}--------------->"
    if !@instructor_student.chek_monthly_fee.present?
      @fee=Fee.create(course_type: @fee_type,amount: @amout,instructor_student_id: @instructor_student.id,instructor_id: @inst_group_class.instructor_id,monthly_detail: params[:monthly_detail],payment_status: 'New')
    else
      @fee = @instructor_student.chek_monthly_fee
    end
    redirect_to payment_options_path(params[:secret_token],@fee.id)
  end

  def view_payment_option_award_test_student
    @instructor_student = InstructorStudent.find_by_secret_token(params[:secret_token])
    @award_test = AwardTest.find(params[:id])
    # @student_contact=@instructor_student.student_contacts.find_by(:primary_contact =>true) if @instructor_student.student_contacts
    @award_test_payment_notification = AwardTestPaymentNotification.find_paid_notification(@award_test.id,@instructor_student.id) || false
    flash[:alert] = "Payment is already done." if @award_test_payment_notification && params[:from_pub_profile].present?
  end
  

  # def pool_info
  #   url = 'http://www.weather.gov.sg/srv/lightning/lightning_alert_ssc.html'
  #   doc = Nokogiri::HTML(open(url, :http_basic_authentication => ['sscops' ,'sscops123']))
  #   rows = doc.css('tr')
  #   if rows.length > 0 
  #     location,risk,time = nil
  #     rows[3..-1].each do |row|
  #       cells = row.css('td')
  #       location,risk,time = cells[0..2].map{|c| c.text}
  #       if location.include?("Swimming Complex")
  #         @lightning_risk = LightningRisk.find_by_location(location)
  #         if !@lightning_risk.blank?
  #           @lightning_risk.update_attributes(:risk => risk , :time => time)
  #         else
  #           @lightning_risk = LightningRisk.create(:location => location, :risk => risk, :time => time)
  #         end  
  #       end  
  #     end 
  #   end

  #   @lightning_risk = LightningRisk.find_by_location(params[:location])
  #   respond_to do |format|
  #     format.js
  #     format.html { render :layout => false}
  #   end
  # end

  # def global_lightning_risk
  #   url = 'http://www.weather.gov.sg/srv/lightning/lightning_alert_ssc.html'

  #   #using nokogiri
  #   doc = Nokogiri::HTML(open(url, :http_basic_authentication => ['sscops' ,'sscops123']))
  #   rows = doc.css('tr')
  #   if rows.length > 0 
  #     location,risk,time = nil
  #     rows[3..-1].each do |row|
  #       cells = row.css('td')
  #       location,risk,time = cells[0..2].map{|c| c.text}
  #       if location.include?("Swimming Complex")
  #         @lightning_risk = LightningRisk.find_by_location(location)
  #         if !@lightning_risk.blank?
  #           @lightning_risk.update_attributes(:risk => risk , :time => time)
  #         else
  #           @lightning_risk = LightningRisk.create(:location => location, :risk => risk, :time => time)
  #         end  
  #       end  
  #     end 
  #   end      
  #   @lightning_risks = LightningRisk.order('location asc')
  # end

private
  
  def instructor_student_params
    params.require(:instructor_student).permit(:student_name,:ic_number,:address,:country,:profile_picture, :age, :gender, :contact, :job_id, :date_of_birth, :is_update, :student_contacts_attributes => [:id, :relationship,:name,:contact, :primary_contact, :email,:_destroy]) rescue {}
  end

  def set_instructor_student
    @instructor_student = InstructorStudent.find_by_secret_token(params[:secret_token])
  end
  def get_invoice
    @invoice = Invoice.find_by_u_sec_number(params[:u_sec_number]) if params[:u_sec_number]
    if @invoice.nil?
      @invoice = ""
    end
  end
end
