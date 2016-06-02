class Manage::DbMessagesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_telerivet, only: [:send_new_message_from_conversation]
  before_action :authenticate_coordinator, except:[:incoiming_mesg_from_db_json,:outgoing_mesg_from_db_json]

  def incoiming_mesg_from_db
  end

  def incoiming_mesg_from_db_json
    respond_to do |format|
      format.html
      format.json { 
        render json: DbMessageIncommingDatatable.new(view_context) }
    end
  end

  def outgoing_mesg_from_db_json
    respond_to do |format|
      format.html
      format.json { 
        render json: DbMessageOutgoingDatatable.new(view_context) }
    end
  end

  def outgoing_mesg_from_db
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    direction = ["Outgoing", "outgoing"]
    @outgoing_message = current_admin_user.messages.where("direction IN (?)", direction).where("to_number LIKE ? OR from_number LIKE ?", "%#{@coordinator_api_setting.telerivet_phone_number}%", "%#{@coordinator_api_setting.telerivet_phone_number}%").order("time_created DESC")
    @last_page = @outgoing_message.last_page_number
  end

  def job_view_message_conversation
    if params[:customer]
      search_by_number = params[:customer]
    else
      instructor = Instructor.find_by_name(params[:instructor])
      search_by_number = instructor.mobile
    end
    @messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{search_by_number}%").order("time_created DESC")
    render :text => @messages.to_json
  end

  def job_view_customer_conversation
    search_by_number = params[:customer]
    @messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{search_by_number}%").order("time_created")
    render :text => @messages.to_json
  end

  def conversation_message
    @phone_number = params[:phone_number]
    @messages = Message.where("to_number LIKE ? OR from_number LIKE ?", "%#{@phone_number}%", "%#{@phone_number}%").order("time_created DESC")
    @telerivet_phone = current_admin_user.coordinator_api_setting.telerivet_phone_number
    @m = current_admin_user.coordinator_api_setting.telerivet_phone_number
      if @m.include?("+") 
        if @m.include?("^")
          @m = @m[4..-1]
        else
          @m = @m[3..-1]
        end 
      else
        if @m.include?("^")
          @m = @m.gsub('^', '')
        else
          @m = @m
        end
      end
    @first_msg = @messages.first
    unless @first_msg.nil? || @first_msg.direction.nil?
      if @first_msg.direction.downcase == "incoming"
        to_number = @first_msg.to_number
        if to_number.include?("+") 
          if to_number.include?("^")
            @client_number = to_number[4..-1]
          else
            @client_number = to_number[3..-1]
          end 
        else
          if to_number.include?("^")
            @client_number = to_number.gsub('^', '')
          else
            @client_number = to_number
          end
        end
        @m = current_admin_user.coordinator_api_setting.telerivet_phone_number
        if @m.include?("+") 
          if @m.include?("^")
            @m = @m[4..-1]
          else
            @m = @m[3..-1]
          end 
        else
          if @m.include?("^")
            @m = @m.gsub('^', '')
          else
            @m = @m
          end
        end
        @conversation = Conversation.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{params[:phone_number]}", "%#{@m}").order("msg_time DESC").uniq
        if @conversation.count > 0
          @conv = @conversation.update_all(:unread_count => 0)
        end
      else
        to_number = @first_msg.from_number
        if to_number.include?("+") 
          if to_number.include?("^")
            @client_number = to_number[4..-1]
          else
            @client_number = to_number[3..-1]
          end
        else
          if to_number.include?("^")
            @client_number = to_number.gsub('^', '')
          else
            @client_number = to_number
          end
        end

        @conversation = Conversation.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{params[:phone_number]}", "%#{@m}").order("msg_time DESC").uniq
        if @conversation.count > 0
          @conv = @conversation.update_all(:unread_count => 0)
        end
      end
    end
    @canned_responses = CannedResponse.all
    unread_message = @messages.where(:message_status => "Unread")
    unread_message.each do |msg|
      msg.update(:message_status => "Read")
    end
    respond_to do |format|
      format.html
    end
  end

  def send_new_message_from_conversation
    logger.info "<-------#{params[:to_number]}------->"
    to_number = params[:to_number].to_i
    content = params[:message_description]
    # Post a new message via API #
    uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      req = Net::HTTP::Post.new(uri.path)
      req.form_data = {
        "content" => content,
        "phone_id" => @phone_id,
        "to_number" => to_number,
        "status_url" => request.base_url.to_s + "/sms_notification",
        "status_secret" => @web_hook_secret
      }
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      to_number = res["to_number"]
      @response = res
    }
    # if !@response['error']
    #   @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
    #   @message = current_admin_user.messages.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @response['from_number'], :starred => @response['starred'])
    #   @conversation = current_admin_user.conversations.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{@message.to_number}", "%#{current_admin_user.coordinator_api_setting.telerivet_phone_number}")
    #   logger.info "<------------#{@conversation.inspect}-------->"
    #   logger.info "<-----#{@time_created}------>"
    #   logger.info "<-----#{@conversation.inspect}----->"
    #   @conversation.first.update(msg_time: @time_created, :msg_des => @message.message_description)
    #   redirect_to manage_conversation_message_path(@message.to_number), notice: 'SMS sent'
    # else
    #   @message = @response
    #   respond_to do |format|
    #     format.js
    #   end
    # end
    if !@response['error']
      @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
      @message = current_admin_user.messages.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @response['from_number'], :starred => @response['starred'])
      if !@response['to_number'].nil?
        if @response['to_number'].include?("+")
          if @response['to_number'].include?("^")
            @client_number = @response['to_number'][4..-1]
          else
            @client_number = @response['to_number'][3..-1]
          end
        else
          @client_number = @response['to_number'].gsub('^', '')
        end
        if @response['from_number'].include?("+")
          if @response['from_number'].include?("^")
            @telerivet_number = @response['from_number'][4..-1]
          else
            @telerivet_number = @response['from_number'][3..-1]
          end
        else
          if @response['from_number'].include?("^")
            @telerivet_number = @response['from_number'].gsub('^', '')
          else
            @telerivet_number = @response['from_number']
          end
        end
        logger.info "<------#{@telerivet_number}--------->"
        @conversation_number = current_admin_user.conversations.where("phone_number = ? AND final_from_number = ?", @client_number, @telerivet_number)
        if @conversation_number.count == 0
          @conversation = current_admin_user.conversations.create(:phone_number => @client_number, :msg_time => @message.time_created , :msg_des => @response['content'], :unread_count => 0, :final_from_number => @telerivet_number)
          logger.info "<-----------#{@conversation.inspect}---------->"
        else
          if @conversation_number.first.msg_time < @message.time_created
            @converation = @conversation_number.first.update(:msg_time => @message.time_created,:msg_des => @response['content'], :unread_count => 0 )
            logger.info "<-----------#{@conversation.inspect}---------->"
          end
        end
      end
      redirect_to manage_conversation_message_path(@message.to_number), notice: 'SMS sent'
    else
      @message = @response
      respond_to do |format|
        format.js
      end
    end 
  end

  def set_unread
    @message = Message.find(params[:id])
    @m = current_admin_user.coordinator_api_setting.telerivet_phone_number
      if @m.include?("+") 
        if @m.include?("^")
          @m = @m[4..-1]
        else
          @m = @m[3..-1]
        end 
      else
        if @m.include?("^")
          @m = @m.gsub('^', '')
        else
          @m = @m
        end
      end
    if @message.update(:message_status => "Unread")
      if @message.direction.downcase == "incoming"
        to_number = @message.from_number
        if to_number.include?("+") 
          if to_number.include?("^")
            @client_number = to_number[4..-1]
          else
            @client_number = to_number[3..-1]
          end 
        else
          if to_number.include?("^")
            @client_number = to_number.gsub('^', '')
          else
            @client_number = to_number
          end
        end
        @conversation = Conversation.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{@client_number}", "%#{@m}").order("msg_time DESC")
        @conv = @conversation.first.update(:unread_count => 1)
      else
        to_number = @message.to_number
        if to_number.include?("+") 
          if to_number.include?("^")
            @client_number = to_number[4..-1]
          else
            @client_number = to_number[3..-1]
          end
        else
          if to_number.include?("^")
            @client_number = to_number.gsub('^', '')
          else
            @client_number = to_number
          end
        end
        @conversation = Conversation.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{@client_number}", "%#{@m}").order("msg_time DESC")
        @conv = @conversation.first.update(:unread_count => 1)
      end
    else
      Rails.logger.info(@message.errors.messages.inspect)
    end
    redirect_to manage_messages_path
  end

  def disconnect_telerivet_account
    @api_settings = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    # @api_settings.update(telerivet_api_key: "",telerivet_project_id: "", telerivet_phone_id: "", :webhook_api_secret => "", :telerivet_phone_number => "", :telerivet_phone_number => "")
    current_admin_user.update_attributes(:is_account_activated => false)
    redirect_to manage_setting_path, :notice => "Account has been disconnected."
  end
  private
    def authenticate_coordinator
      if !admin_user_signed_in?
        redirect_to manage_root_path
      end
    end

    def set_telerivet
      # @telerivet = ApiSetting.first
      @telerivet = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
      @api_key = @telerivet.telerivet_api_key
      @project_id = @telerivet.telerivet_project_id
      @phone_id = @telerivet.telerivet_phone_id
      @web_hook_secret = @telerivet.webhook_api_secret
    end
    def telerivet_api_url
      "https://api.telerivet.com/v1"
    end
end