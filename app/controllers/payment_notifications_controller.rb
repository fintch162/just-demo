class PaymentNotificationsController < InheritedResources::Base
  protect_from_forgery :except => [ :create_payment_notifications ]
  include InstructorStudentsHelper
  def create_payment_notifications
    if params[:item_name1]
      str = params[:item_name1].scan(/\d+/)
      invoice_id = str[1].strip
      job_ref = str[0].strip
    elsif params[:order_id]
      str = params[:order_id].scan(/\d+/)
      invoice_id = str[1].strip
      job_ref = str[0].strip
    end

    if params[:payment_status]
      status = params[:payment_status]
    elsif params[:status]
      status = params[:status]
    end

    if params[:mc_gross]
      total_amount = params[:mc_gross]
      paid_by = "Paypal"
    elsif params[:total_amount]
      total_amount = params[:total_amount]
      paid_by = "Xfers"
    end
    PaymentNotification.create!(:params => params, :paid_by => paid_by, :payment_date => params[:created_at],
                                :transaction_id => params[:txn_id], :invoice_id => invoice_id, :status => status,
                                :amount => total_amount, :job_ref => job_ref)
    render :nothing => true
  end

  def return_response_reddot_payment_red_dot
    # params["order_number"]=params["order_number"].split('_')[1].gsub('inv','')
    @payment_notification = PaymentNotification.find_by_merchant_reference(params["merchant_reference"])
    if !@payment_notification
      invoice_number = params["merchant_reference"].split('_')[0]
      @invoice = Invoice.find_by_invoice_number(invoice_number)

      if !params["error_code"].present?
        PaymentNotification.create!(:params => params, :paid_by => "RedDot V/M", :transaction_id => params["transaction_id"],
                                  :invoice_id => @invoice.invoice_number, :status => params["result"], :amount => params["amount"],
                                  :job_ref => @invoice.job_id,merchant_reference: params["merchant_reference"])
        redirect_to view_pa_path(@invoice.job_id, @invoice.u_sec_number)+'?paid_by=red_dot'
      else
        PaymentNotification.create!(:params => params, :paid_by => "RedDot V/M",
                                  :invoice_id => @invoice.invoice_number, :status => params["result"], :amount => params["amount"],
                                  :job_ref => @invoice.job_id)
        redirect_to view_pa_path(@invoice.job_id, @invoice.u_sec_number)+'?paid_by=red_dot&error_code='+params["error_code"]
      end
    else
      redirect_to view_pa_path(@invoice.job_id, @invoice.u_sec_number)+'?paid_by=red_dot'
    end
  end
 
  def return_response_reddot_payment_enets
    # params["order_number"]=params["order_number"].split('_')[0]
    @payment_notification = PaymentNotification.find_by_merchant_reference(params["merchant_reference"])
    if !@payment_notification
      # @invoice = Invoice.find_by_invoice_number(params["order_number"])
      invoice_number = params["merchant_reference"].split('_')[0]
      @invoice = Invoice.find_by_invoice_number(invoice_number)
      if !params["error_code"].present?
      PaymentNotification.create!(:params => params, :paid_by => "ENETS", :transaction_id => params["transaction_id"],
                                  :invoice_id => @invoice.invoice_number, :status => params["result"], :amount => params["amount"],
                                  :job_ref => @invoice.job_id,merchant_reference: params["merchant_reference"])
      redirect_to view_pa_path(@invoice.job_id, @invoice.u_sec_number)+'?paid_by=red_dot'
      else
        PaymentNotification.create!(:params => params, :paid_by => "ENETS", :transaction_id => params["transaction_id"],
                                  :invoice_id => @invoice.invoice_number, :status => params["result"], :amount => params["amount"],
                                  :job_ref => @invoice.job_id)
        redirect_to view_pa_path(@invoice.job_id, @invoice.u_sec_number)+'?paid_by=red_dot&error_code='+params["error_code"]
      end
    end
  end

  def get_notification
    GCM.host = 'https://android.googleapis.com/gcm/send'
    GCM.format = :json
    GCM.key = "AIzaSyCAKQG1UEx7M-G9UX7lTBOu1X1V3c9_EcA"

    # webhook_secret = 'UN6FNK646UDCD2X2T993QCE7DUNNTCEN'
    # webhook_secret = '4X2PFGEQWLZEXF3ZRFERK3PWLNTNZQA6'

    @response = params
    @coordinator_setting =  CoordinatorApiSetting.find_by_webhook_api_secret(@response['secret'])
    if @coordinator_setting.nil?
      puts "Invalid webhook secret"
    else 
      @coordinator = Coordinator.find(@coordinator_setting.coordinator_id)
      if @response['event'] == 'incoming_message'
        @message = Message.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s), :from_number => @response['from_number'], :starred => @response['starred'], :coordinator_id => @coordinator_setting.coordinator_id, :message_status => "Unread")
        if !@response['from_number'].nil?
          if @response['from_number'].include?("+")
            if @response['from_number'].include?("^")
              @client_number = @response['from_number'][4..-1]
            else
              @client_number = @response['from_number'][3..-1]
            end
          else
            @client_number = @response['from_number'].gsub('^', '')
          end
          if @response['to_number'].include?("+")
            if @response['to_number'].include?("^")
              @telerivet_number = @response['to_number'][4..-1]
            else
              @telerivet_number = @response['to_number'][3..-1]
            end
          else
            if @response['to_number'].include?("^")
              @telerivet_number = @response['to_number'].gsub('^', '')
            else
              @telerivet_number = @response['to_number']
            end
          end
          @conversation_number = @coordinator.conversations.where("phone_number = ? AND final_from_number = ?", @client_number, @telerivet_number)
          if @conversation_number.count == 0
            @conversation = @coordinator.conversations.create(:phone_number => @client_number, :msg_time => @message.time_created , :msg_des => @response['content'], :unread_count => 1, :final_from_number => @telerivet_number)
          else
            if @conversation_number.first.msg_time < @message.time_created
              @unread_count = @conversation_number.first.unread_count + 1
              @converation = @conversation_number.first.update(:msg_time => @message.time_created,:msg_des => @response['content'], :unread_count => @unread_count )
            end
          end
        end
      end
    end


    registrationIds = MobileDevice.where(:status => "Active", :phoneNumber => @message.to_number).pluck(:device_registration_id) 
    destination = registrationIds

    # data = { :title => "Matchmaker", :message => @message.message_description }
    data = { :title => @message.to_number, :message => @message.message_description, :date => @message.time_created }
    if destination.count > 0
      # noti = GCM.send_notification( destination, data )
      noti = GCM.send_notification( destination, data )
    end
  end


  def instructor_notification
    @response = params
    @instructor =  AdminUser.find_by_instructor_webhook_api_secret(@response['secret'])
    logger.info "<------------#{@instructor.inspect}------------->"
    if @instructor.nil?
      puts "Invalid webhook secret"
    else 
      logger.info "|-------------- #{@response} --------------|"
      if @response['event'] == 'incoming_message'
        if !@response['from_number'].nil?
          format_phon_number #(instructor_students)helper called
          logger.info "<-----------#{@client_number}----#{@telerivet_number}----->"
          @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
          @inst_conversation_number = @instructor.instructor_conversations.where("phone_number = ? AND from_number = ?", @telerivet_number, @client_number)
          if @inst_conversation_number.count == 0
            @inst_conversation = @instructor.instructor_conversations.create(:phone_number => @telerivet_number, :msg_time => @time_created , :msg_des => @response['content'], :unread_count => 1, :from_number => @client_number)
          else
            if @inst_conversation_number.first.msg_time < @time_created
              @inst_conversation = @inst_conversation_number.first.update(:msg_time => @time_created,:msg_des => @response['content'], :unread_count =>  @inst_conversation_number.first.unread_count + 1 )
              @inst_conversation = @inst_conversation_number.first
            end
          end
          @message = @instructor.instructor_messages.create(:to_number => @telerivet_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number =>  @client_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id)
        end
      end
    end
    render :nothing => true
  end
  def sms_status
    @response = params
    @msg = Message.find_by_unique_message_id(@response["id"])
    if !@msg.nil?
      @msg.update(:status => params["status"])
    end
  end

  def inst_sms_status
    @response = params
    @msg = InstructorMessage.find_by_unique_message_id(@response["id"])
    if !@msg.nil?
      @msg.update(:status => params["status"])
    end
    render :nothing => true
  end

  def red_dot_notification
    notification_response =  request.body.read
    response_status = ''
    transaction_id = ''
    amount = ''
    invoice_num = ''
    inv = ''
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
        merchant = p[0]
        invoice_num=p[1].split('_')[0]
        inv = p[1]

      end
    end

    @payment_notification  = PaymentNotification.find_by(transaction_id: transaction_id)
    if !@payment_notification.nil?

      mn = @payment_notification.update_attributes(:status => response_status)
      logger.info "<----------#{mn}---------->"
    else
      @invoice = Invoice.find_by_invoice_number(inv.split('_')[0])
      PaymentNotification.create!(:params => notification_response, :paid_by => "RedDot V/M", :transaction_id => transaction_id,
                                :invoice_id => invoice_num, :status => response_status, :amount =>amount,
                                :job_ref => @invoice.job_id,merchant_reference: merchant)
    end
    render :nothing => true
  end
end
