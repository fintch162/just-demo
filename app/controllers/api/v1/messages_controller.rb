class Api::V1::MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [ :create, :reply ]
  before_action :set_telerivet, only: [:reply ]
  before_action :list_all_messages, only: [ :index]
  before_action :check_authentication_token

  # change for new api
  def index
    render json: @withNames
  end

  # change for new api
  def show
    @phone_number = params[:id]
    @messages = Message.where("to_number LIKE ? OR from_number LIKE ?", "%#{@phone_number}%", "%#{@phone_number}%").order("time_created DESC").limit(20).reverse
    @first_msg = @messages.first
    unless @first_msg.nil? || @first_msg.direction.nil?
      check_message_direction(@first_msg)
      @conversation.first.update(:unread_count => 0)
    end
    render :json => @messages
  end

  # change for new api
  def set_unread
    @message = Message.find(params[:id])
    @message.update_attributes(:message_status => "Unread")
    check_message_direction(@message)
    @conversation.first.update(:unread_count => 1)
    render json: ''
  end

  # change for new api
  def check_message_direction(message)
    @telerivetPhone = @user.coordinator_api_setting.telerivet_phone_number
    coordinatorPhone = remove_state_code_from_message_number(@telerivetPhone)
    if message.direction.downcase == "incoming"
      @to_number = message.from_number
    else
      @to_number = message.to_number
    end
    @client_number = remove_state_code_from_message_number(@to_number)
    @conversation = Conversation.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{@client_number}", "%#{coordinatorPhone}").order("msg_time DESC")
  end

  # change for new api
  def create
    logger.info "<-----#{request.base_url}---------#{params}------------>"
    @response = TelerivetService.new(params).create(request.base_url.to_s)
    logger.info "<-----#{@response}----------->"
    # exit
    user = @user
    # user = AdminUser.find(params[:userId])
    if !@response['error']
      @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
      @message = user.messages.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @response['from_number'], :starred => @response['starred'])
      if !@response['to_number'].nil?

        @client_number = remove_state_code_to_message_number(@response['to_number'])
        @telerivet_number = remove_state_code_from_message_number(@response['from_number']) 
        @conversation_number = user.conversations.where("phone_number = ? AND final_from_number = ?", @client_number, @telerivet_number)
        if @conversation_number.count == 0
          @conversation = user.conversations.create(:phone_number => @client_number, :msg_time => @message.time_created , :msg_des => @response['content'], :unread_count => 0, :final_from_number => @telerivet_number)
        else
          if @conversation_number.first.msg_time < @message.time_created
            @converation = @conversation_number.first.update(:msg_time => @message.time_created,:msg_des => @response['content'], :unread_count => 0 )
          end
        end
      end
      render json: @message
    else
      render json: {status: 404}
    end  
  end

  # change for new api
  def incoming_messages
    @direction = ["incoming", "Incoming"]
    fetch_message(@direction)
    render json: @messages
  end

  #change for new api
  def outgoing_messages
    @direction = ["Outgoing", "outgoing"]
    fetch_message(@direction)
    render json: @messages
  end

  #change for new api
  def fetch_message(direction)
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(params[:id])
    @messages = Message.where(:coordinator_id => params[:id]).where("direction IN (?)", direction).where("to_number LIKE ? OR from_number LIKE ?", "%#{@coordinator_api_setting.telerivet_phone_number}%", "%#{@coordinator_api_setting.telerivet_phone_number}%").order("time_created DESC")
  end

  #change for new api
  def load_more_message
    @phone_number = params[:id]
    @messages = @messages = Message.where("to_number LIKE ? OR from_number LIKE ?", "%#{@phone_number}%", "%#{@phone_number}%").order("time_created DESC")
    @messages = @messages.where("id < ?",params[:offset]).limit(20).reverse
    render :json => @messages
  end

  #change for new api
  def checkStatus
    @messages = Message.find(params[:id])
    render :json => @messages
  end

  def view_conversation
    @phone_number = params[:phone_number]
    current_admin_user = AdminUser.find_by_authentication_token(params[:authenticationToken])

    if current_admin_user
      @messages = current_admin_user.messages.where("to_number LIKE ? OR from_number LIKE ?", "%#{@phone_number}%", "%#{@phone_number}%").order("time_created DESC")
      @telerivet_phone = current_admin_user.coordinator_api_setting.telerivet_phone_number
      @first_msg = @messages.first
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
        @conversation = current_admin_user.conversations.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{params[:phone_number]}", "%#{current_admin_user.coordinator_api_setting.telerivet_phone_number}")
        if @conversation.count > 0
          @conv = @conversation.first.update(:unread_count => 0)
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

        @conversation = current_admin_user.conversations.where("phone_number LIKE ? AND final_from_number LIKE ?", "%#{params[:phone_number]}", "%#{current_admin_user.coordinator_api_setting.telerivet_phone_number}")
        if @conversation.count > 0
          @conv = @conversation.update_all(:unread_count => 0)
        end
      end
      unread_message = @messages.where(:message_status => "Unread")
      unread_message.each do |msg|
        msg.update(:message_status => "Read")
      end
      # @messages = @messages.where('to_number = ? && from_number = ?',@telerivet_phone, @telerivet_phone)
    else
      @messages = false
    end
    logger.info "============== #{@messages.count} =============="
    render json: @messages
  end

  def reply
    user = AdminUser.find(params[:userId])
    to_number = params[:toNumber].to_i
    content = params[:messageBody]
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
        "to_number" => to_number
      }
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      to_number = res["to_number"]
      @response = res
    }

    if !@response['error']
      @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
      @message = user.messages.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @response['from_number'], :starred => @response['starred'])

      if !@response['to_number'].nil?
        
        @client_number = remove_state_code_to_message_number(@response['to_number']) # this will call remove_state_code_to_message_number method to filter number 
        @telerivet_number = remove_state_code_from_message_number(@response['from_number']) # this will call remove_state_code_from_message_number method to filter number 

        @conversation_number = user.conversations.where("phone_number = ? AND final_from_number = ?", @client_number, @telerivet_number)
        if @conversation_number.count == 0
          @conversation = user.conversations.create(:phone_number => @client_number, :msg_time => @message.time_created , :msg_des => @response['content'], :unread_count => 0, :final_from_number => @telerivet_number)
        else
          if @conversation_number.first.msg_time < @message.time_created
            @converation = @conversation_number.first.update(:msg_time => @message.time_created,:msg_des => @response['content'], :unread_count => 0 )
          end
        end
      end
      render :json => @message
    else
      render :text => @response
    end
  end

  def count_unread_notification
    user = params[:user]
    userObj = AdminUser.find(user)

    notification = userObj.conversations.where.not(unread_count: 0).count
    render :json => notification
  end

  def mark_conversation_as_unread
    @converstaions = Conversation.where('phone_number LIKE ?', remove_state_code_to_message_number(params[:phoneNumber]))
    @converstaion = @converstaions.update_all(:unread_count => 1)
    render :json => "Done"
  end

  private
    def set_telerivet
      userId = params[:userId]
      @telerivet = CoordinatorApiSetting.find_by_coordinator_id(userId)
      @api_key = @telerivet.telerivet_api_key
      @project_id = @telerivet.telerivet_project_id
      @phone_id = @telerivet.telerivet_phone_id
    end

    def telerivet_api_url
      "https://api.telerivet.com/v1"
    end

    # change for new api
    def remove_state_code_to_message_number(number)
      if number.include?("+")
        if number.include?("^")
          @client_number = number[4..-1]
        else
          @client_number = number[3..-1]
        end
      else
        @client_number = number.gsub('^', '')
      end
    end

    def remove_state_code_from_message_number(number)
      if number.include?("+")
        if number.include?("^")
          @telerivet_number = number[4..-1]
        else
          @telerivet_number = number[3..-1]
        end
      else
        if number.include?("^")
          @telerivet_number = number.gsub('^', '')
        else
          @telerivet_number = number
        end
      end
    end

    # change for new api
    def list_all_messages
      user = params[:user]
      logger.info "<-------#{user}------------->"
      userObj = AdminUser.find(user)
      if userObj.type == "Coordinator"
        coordinatorApiSetting = CoordinatorApiSetting.find_by_coordinator_id(user)
        @telerivetPhoneNumber = coordinatorApiSetting.telerivet_phone_number
      else
        @telerivetPhoneNumber = userObj.telerivet_phone_number
      end
      @telerivetPhoneNumber = remove_state_code_from_message_number(@telerivetPhoneNumber)
      @converstaions = Conversation.where("final_from_number  LIKE ?", @telerivetPhoneNumber).order("msg_time DESC").uniq.paginate(:page => params[:page], :per_page => 50)
      @withNames = []
      @phone_number = []
      @converstaions.each do |converstaion|
        phoneNumber = remove_state_code_from_message_number(converstaion.phone_number)
        if !@phone_number.include?(phoneNumber)
          @phone_number << phoneNumber
          i = Instructor.find_by_mobile(phoneNumber)
          if !i.nil?
            converstaion.from_number = i.name.capitalize  
          end
          @withNames << converstaion
        end
      end
    end
end