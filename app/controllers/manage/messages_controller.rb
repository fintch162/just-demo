class Manage::MessagesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  require 'telerivet'
  require 'net/https'
  require 'open-uri'

  respond_to :html, :json
  PAGE_SIZE = 30
  JOB_MARKER = 20
  before_action :set_telerivet, except: [:index]
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  add_breadcrumb "Home", :root_path
  add_breadcrumb "SMS", :manage_messages_path, :only => [:index, :outgoing_messages, :incoming_messages]
  add_breadcrumb "outgoing SMS", :manage_outgoing_messages_path, :only => [:outgoing_messages]
  add_breadcrumb "Incomming SMS", :manage_incoming_messages_path, :only => [:incoming_messages]

  before_action :check_user_permission, only: [ :index, :load_more_messages, :create, :outgoing_messages, :incoming_messages, :conversastions_messages, :job_message_send, :job_conversation, :load_msg, :cust_load_msg, :load_more_job_messages, :customer_job_conversation, :get_instructor, :get_contacts_by_project_id ]


  # def index
  #   uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts")

  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  #   http.ca_file = "#{Rails.root}/certificate/cacert.pem"
  #   http.start {
  #     # req = Net::HTTP::Get.new(uri.path)
  #     req = Net::HTTP::Get.new(uri.path + "?count=true&page_size=#{PAGE_SIZE}&sort_dir=desc&sort=last_message_time")
  #     req.basic_auth @api_key, ''    
  #     res = JSON.parse(http.request(req).body)
  #     @messages = res
  #   }
  #   session[:conversation_page] = PAGE_SIZE
  #   render :layout => "manage"

  #   # @converstaions = current_admin_user.conversations.order("msg_time DESC").paginate(:page => params[:page], :per_page => 20)
  #   # @final_uniq_number = @final_msg_converstation.sort_by{|e| e[:time_created]}.reverse.paginate(:page => params[:page], :per_page => 20)   
  #   # logger.info "<----------#{@final_uniq_number}------------------->"
  # end

  
  def index
    # uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts")

    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    # http.start {
    #   # req = Net::HTTP::Get.new(uri.path)
    #   req = Net::HTTP::Get.new(uri.path + "?count=true&page_size=#{PAGE_SIZE}&sort_dir=desc&sort=last_message_time")
    #   req.basic_auth @api_key, ''    
    #   res = JSON.parse(http.request(req).body)
    #   @messages = res
    # }
    # session[:conversation_page] = PAGE_SIZE
    # render :layout => "manage"
    # @to_number = current_admin_user.messages.where("direction IN(?)", ["outgoing", "Outgoing"]).pluck(:to_number).uniq
    # @from_number = current_admin_user.messages.where("direction IN(?)", ["incoming", "Incoming"]).pluck(:from_number).uniq
    # @uniq_number = @to_number + @from_number
    # @final_uniq_number = @uniq_number.uniq
    # @final_number = []
    # @final_uniq_number.each do |f_number|
    #   if !f_number.nil?  
    #     if f_number.include?("+")
    #       if f_number.include?("^")
    #         @final_number << f_number[4..-1]
    #       else
    #         @final_number << f_number[3..-1]
    #       end
    #     else
    #       @final_number << f_number.gsub('^', '')
    #     end
    #   end
    # end
    # @final_uniq_number = @final_number.uniq
    # @final_msg_converstation = []
    # @final_uniq_number.each do |message|
    #   @msg_latest = @current_admin_user.messages.where("to_number LIKE ? OR from_number LIKE ?", "%#{message}","%#{message}").order("time_created DESC").first

    #   @final_msg_converstation << {
    #                                 :id => @msg_latest.id,
    #                                 :messge_number => message,
    #                                 :time_created => @msg_latest.time_created,
    #                                 :message_description => @msg_latest.message_description,
    #                                 :message_count => @current_admin_user.messages.where("to_number LIKE ? OR from_number LIKE ?", "%#{message}","%#{message}").where(:message_status => "Unread").order("time_created DESC").count
    #                               }
    # end

    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    if current_admin_user.is_account_activated?
      telerivet_phone_number = @coordinator_api_setting.telerivet_phone_number
      if telerivet_phone_number.include?("+")
        if telerivet_phone_number.include?("^")
          telerivet_phone_number = telerivet_phone_number[4..-1]
        else
          telerivet_phone_number = telerivet_phone_number[3..-1]
        end
      else
        telerivet_phone_number = telerivet_phone_number.gsub('^', '')
      end 
      @converstaions = Conversation.where("final_from_number LIKE ?", "#{telerivet_phone_number}").order("msg_time DESC").uniq.paginate(:page => params[:page], :per_page => 20)
      # @conversations_unread = Conversation.where("final_from_number LIKE ?", "#{telerivet_phone_number}").order("unread_count DESC").uniq.paginate(:page => params[:page], :per_page => 20)
    else
      @converstaions = "Disconnected"
    end
    # @final_uniq_number = @final_msg_converstation.sort_by{|e| e[:time_created]}.reverse.paginate(:page => params[:page], :per_page => 20)   

  end

  def unread_messages
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    if current_admin_user.is_account_activated?
      telerivet_phone_number = @coordinator_api_setting.telerivet_phone_number
      if telerivet_phone_number.include?("+")
        if telerivet_phone_number.include?("^")
          telerivet_phone_number = telerivet_phone_number[4..-1]
        else
          telerivet_phone_number = telerivet_phone_number[3..-1]
        end
      else
        telerivet_phone_number = telerivet_phone_number.gsub('^', '')
      end 
        @conversations_unread = Conversation.where("final_from_number LIKE ?", "#{telerivet_phone_number}").where("unread_count > 0").order("msg_time DESC").uniq.paginate(:page => params[:page], :per_page => 20)
    else
      @conversations_unread = "Disconnected"
    end
  end

  def load_more_messages
    phone_number = params[:phone]
    tr = Telerivet::API.new(@api_key)
    project = tr.get_project_by_id(@project_id)

    contact = project.get_or_create_contact({
      'phone_number' => phone_number
    })

    @contact_id = contact.id
    @contact_name = contact.name

    uri = URI("#{telerivet_api_url}/contacts/#{@contact_id}/messages")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    next_marker = session[:next_marker]
    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      req = Net::HTTP::Get.new(uri.path + "?page_size=6&sort_dir=desc&marker=#{next_marker}")
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      @conversastions_messages = res
    }
    if @conversastions_messages["next_marker"] == nil
      session[:next_marker] = ""
    else
      session[:next_marker] = @conversastions_messages["next_marker"]
    end
    get_contacts_by_project_id

    respond_to do |format|
      format.html
      format.js { render :layout => "manage" }
    end
  end

  def create
    to_number = message_params[:to_number]
    content = message_params[:message_description]
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
    logger.info "------ #{@response.inspect} -------"

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
      redirect_to manage_messages_path, :notice => "Message sent successfully"
    else
      redirect_to manage_messages_path, :alert => "Message sending failed please check api credential"
    end  
    
  end

  def outgoing_messages
    if params[:conversation]
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts/#{params[:c_p_id]}/messages")
      outgoing_message_by_c_id = '&direction=outgoing'
    else
      # Get list of all outgoing messages #
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      req = Net::HTTP::Get.new(uri.path + "?sort_dir=desc#{outgoing_message_by_c_id}")
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      @outgoing_messages = res
    }

    get_contacts_by_project_id

    respond_to do |format|
      format.html
      format.js { render :layout => "manage" }
    end
  end

  def incoming_messages
    if params[:conversation]
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts/#{params[:c_p_id]}/messages")
      incoming_message_by_c_id = '&direction=incoming'
    else
      # Get list of all Incomming messages #
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/incoming")
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      req = Net::HTTP::Get.new(uri.path + "?sort_dir=desc#{incoming_message_by_c_id}")
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      @incoming_messages = res
    }
    get_contacts_by_project_id

    respond_to do |format|
      format.html
      format.js { render :layout => "manage" }
    end
  end

  def conversastions_messages
    phone_number = params[:to_number]
    tr = Telerivet::API.new(@api_key)
    project = tr.get_project_by_id(@project_id)

    contact = project.get_or_create_contact({
      'phone_number' => phone_number
    })

    @contact_id = contact.id
    @contact_name = contact.name
    @c_phone_number = contact.phone_number

    uri = URI("#{telerivet_api_url}/contacts/#{@contact_id}/messages")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      # req = Net::HTTP::Get.new(uri.path + "?&page_size=5")

      req = Net::HTTP::Get.new(uri.path + "?page_size=#{JOB_MARKER}&sort_dir=desc")

      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      @conversastions_messages = res
    }
    session[:next_marker] = @conversastions_messages["next_marker"]

    get_contacts_by_project_id

    respond_to do |format|
      format.html
      format.js { render :layout => "manage" }
    end
  end


  def job_message_send
    begin
      timeout(50) do
        customer = params[:customer]
        message_body = params[:message_body]
        @job = Job.find(params[:job_id]) if params[:job_id].present?
        @telerivet = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)

        if params[:instructor]
          instructor = Instructor.find_by_name(params[:instructor])
        end
        if instructor
          to_number = instructor.mobile
          @job.update_attributes(:message_to_instructor => message_body)
        else
          to_number = params[:customer]
          @job.update_attributes(:message_to_customer => message_body)
        end

        project_id = @telerivet.telerivet_project_id

        # Post a new message via API #
        uri = URI("#{telerivet_api_url}/projects/#{project_id}/messages/outgoing")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        http.ca_file = "#{Rails.root}/certificate/cacert.pem"
        http.start {
          req = Net::HTTP::Post.new(uri.path)
          req.form_data = {
            "content" => message_body,
            "to_number" => to_number,
            "status_url" => request.base_url.to_s + "/sms_notification",
            "status_secret" => @web_hook_secret

          }
          req.basic_auth @telerivet.telerivet_api_key, ''    
          res = JSON.parse(http.request(req).body)
          if instructor
            instructor.update_attributes(:tr_phone_id => res["phone_id"], :tr_contact_id => res["contact_id"])
          end
          @response = res
        }
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
            else
              if @conversation_number.first.msg_time < @message.time_created
                @converation = @conversation_number.first.update(:msg_time => @message.time_created,:msg_des => @response['content'], :unread_count => 0 )
              end
            end
          end
          render :text => @response.to_json 
        else
          render :text => @response.to_json 
        end 
        # if !@response['error']
        #   if (@response["status"] != "failed" || !@response['error'])
        #     # @time_created = DateTime.strptime(@response['time_created'].to_s, "%s")
        #       logger.info "<-----#{@response.inspect}----->"
        #     @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
        #     @message = current_admin_user.messages.create(:to_number => @response["to_number"], :message_description => @response["content"], :unique_message_id => @response["id"], :phone_id => @response["phone_id"], :contact_id => @response["contact_id"], :direction => @response["direction"], :status => @response["status"], :project_id => @response["project_id"], :message_type => @response["message_type"], :source => @response["source"], :time_created => @time_created, :from_number => @response["from_number"])
            
        #     @conversation = current_admin_user.conversations.where('phone_number LIKE :to_number AND final_from_number LIKE :from_number', {:to_number => @response["to_number"], :from_number => @response["from_number"]} )
        #     if @conversation.count == 0
        #       @conversation = current_admin_user.conversations.create(:phone_number => @response["to_number"], :msg_time => @time_created , :msg_des => @response['content'], :unread_count => 1, :final_from_number => @response["from_number"])
        #     else
        #       if @conversation.first.msg_time < @time_created
        #         @unread_count = @conversation.first.unread_count + 1
        #         @converation = @conversation.first.update(:msg_time => @message.time_created,:msg_des => @response['content'])
        #       end
        #     end
        #     render :text => @response.to_json
        #   else
        #     render :text => @response.to_json 
        #   end
        # else
        #   render :text => @response.to_json 
        # end
        
      end
    rescue Timeout::Error, SocketError => e
      render :text => e, status: 503
    end
  end

  def job_conversation
    @instructor = Instructor.find(params[:instructor])
    # if !instructor.nil?
    #   search_by_number = instructor.mobile
    #   @messages = current_admin_user.messages.where("to_number LIKE :search_by_number OR from_number LIKE :search_by_number", :search_by_number => "%#{search_by_number}%").order("created_at DESC").paginate(:page => params[:page])
    # @messages = @messages.to_json
    # else
    #   @messages = []
    #   @messages = @messages.to_json
    # end

    #------------messages load using conntact-id------------
    begin
      tr = Telerivet::API.new(@api_key)
      project = tr.get_project_by_id(@project_id)

      contact = project.get_or_create_contact({
        'name' => @instructor.name,
        'phone_number' => @instructor.mobile
      })

      contact_id = contact.id
    rescue Exception => exc
      @error=true
    end
    #--------------------------------------------------------
    # @c_phone_number = contact.phone_number
    # contact_id = @instructor.tr_contact_id
    # # max = DateTime.now.strftime('%Q')

    # uri = URI("https://api.telerivet.com/v1/contacts/#{contact_id}/messages")
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # # you will need to download SSL certificates from https://telerivet.com/_media/cacert.pem .
    # http.ca_file = "#{Rails.root}/certificate/cacert.pem"

    # http.start {
    #   req = Net::HTTP::Get.new(uri.path + "?sort_dir=desc&page_size=#{JOB_MARKER}&count=true")
    #   req.basic_auth @api_key, ''
    #   res = JSON.parse(http.request(req).body)
    #   # @messages = res.merge({ "mobile" => "#{instructor.mobile}", "c_phone_number" => "#{@c_phone_number}", "instructorName" => "#{instructor.name}", "instructorId" => "#{instructor.id}" })
    # }
      # @messages = Message.where(contact_id: contact_id).order("time_created DESC").paginate(page: 1)
      @messages=Message.where("to_number LIKE ? OR from_number LIKE ?","%#{@instructor.mobile}%","%#{@instructor.mobile}%").order("time_created DESC").paginate(page: 1)
    # render :js
  end

  def load_msg
    load_more_job_messages
  end

  def cust_load_msg
    load_more_job_messages
  end

  def load_more_job_messages
    @instructor = Instructor.find(params[:inst])
    #------------messages load using conntact-id------------
    # tr = Telerivet::API.new(@api_key)
    # project = tr.get_project_by_id(@project_id)

    # contact = project.get_or_create_contact({
    #   'name' => @instructor.name,
    #   'phone_number' => @instructor.mobile
    # })

    # contact_id = contact.id
    #-------------------------------------------------
    # contact_id = @instructor.tr_contact_id
    # @messages = Message.where(contact_id: contact_id).order("time_created DESC").paginate(page: params[:page])
    @messages=Message.where("to_number LIKE ? OR from_number LIKE ?","%#{@instructor.mobile}%","%#{@instructor.mobile}%").order("time_created DESC").paginate(page: params[:page])
    if params[:page].to_i > @messages.total_pages
      @messages = []
    end
  end

  def customer_job_conversation
    @job = Job.find(params[:job_id])
  
    # if !@api_key.blank?
    #   begin
    #     tr = Telerivet::API.new(@api_key)
    #     project = tr.get_project_by_id(@project_id)

    #     contact = project.get_or_create_contact({
    #       'name' => @job.lead_contact,
    #       'phone_number' => @job.lead_contact
    #     })
    #     contact_id = contact.id
    #   rescue Exception => exc
    #     @error=true
    #   end

      # uri = URI("https://api.telerivet.com/v1/contacts/#{contact_id}/messages")
      # http = Net::HTTP.new(uri.host, uri.port)
      # http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      # # you will need to download SSL certificates from https://telerivet.com/_media/cacert.pem .
      # http.ca_file = "#{Rails.root}/certificate/cacert.pem"

      # http.start {
      #   req = Net::HTTP::Get.new(uri.path + "?sort_dir=desc&page_size=#{JOB_MARKER}")
      #   req.basic_auth @api_key, ''    

      #   res = JSON.parse(http.request(req).body)
      #   @messages = res.merge({ "contact_number" => "#{contact.phone_number}" })
      # }
      # @messages = @messages.to_json
      # @messages = Message.where(contact_id: contact_id)
      @messages=Message.where("to_number LIKE (?) OR from_number LIKE (?)","%#{@job.lead_contact}%","%#{@job.lead_contact}%").order("time_created DESC")
      # render :text => @messages
    # else
    #   # render :text => "Please set your telerivet api setting."
    # end
  end

  def get_instructor
    begin
      timeout(50) do
        @instructor = Instructor.find_by_name(params[:instructor])
        if params[:short_nm]
          render :text => @instructor.short_name if @instructor
        else
          render :text => @instructor.mobile if @instructor
        end
      end
    rescue Timeout::Error, SocketError => e
      render :text => e, status: 503
    end
  end

  def get_contacts_by_project_id
    uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    http.start {
      req = Net::HTTP::Get.new(uri.path)
      req.basic_auth @api_key, ''    
      res = JSON.parse(http.request(req).body)
      @contact = res
    }

    @arr_contact = []
    @contact["data"].each do |c|
      @arr_contact << [c["name"], c["phone_number"]]
    end
  end

  def next_page
    uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
    session[:conversation_page] = session[:conversation_page] + PAGE_SIZE
    http.start {
      # req = Net::HTTP::Get.new(uri.path)
      req = Net::HTTP::Get.new(uri.path + "?count=true&page_size=#{PAGE_SIZE}&sort_dir=desc&sort=last_message_time&offset=#{session[:conversation_page]}")
      req.basic_auth @api_key, ''
      res = JSON.parse(http.request(req).body)
      @messages = res
    }
    render :layout => "manage"
  end

  def prev_page
    uri = URI("#{telerivet_api_url}/projects/#{@project_id}/contacts")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    session[:conversation_page] = session[:conversation_page] - PAGE_SIZE
    if session[:conversation_page] < 0
      session[:conversation_page] = PAGE_SIZE
    else
      http.ca_file = "#{Rails.root}/certificate/cacert.pem"
      http.start {
        # req = Net::HTTP::Get.new(uri.path)
        req = Net::HTTP::Get.new(uri.path + "?count=true&page_size=#{PAGE_SIZE}&sort_dir=desc&sort=last_message_time&offset=#{session[:conversation_page]}")
        req.basic_auth @api_key, ''
        res = JSON.parse(http.request(req).body)
        @messages = res
      }
    end
    render :layout => "manage"
  end

  def import
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    # @messages = current_admin_user.messages.import_f(params[:file])
    @duplicate = 0
    @fresh = 0
    Message.benchmark('create 100 message with activerecord-import gem') do
      columns = [ :time_created, :from_number, :to_number, :contact_name, :message_description, :message_type, :direction, :status, :starred, :labels, :contact_id, :unique_message_id ]
      values = []
      CSV.foreach(params[:file].path, headers: true) do |row|
        if current_admin_user.messages.find_by(:unique_message_id => row['unique_message_id'])
          @duplicate = @duplicate + 1
        else
          @fresh = @fresh + 1
          values << [DateTime.parse(row['created_at']).change(:offset => "+0800"), row['from_number'], row['to_number'], row['contact_name'], row['message_description'], row['message_type'], row['direction'], row['status'], row['starred'], row['labels'], row['contact_id'], row['unique_message_id'] ]
          if row['direction'].downcase == "incoming"
            if !row['from_number'].nil?
              if row['from_number'].include?("+")
                if row['from_number'].include?("^")
                  @client_number = row['from_number'][4..-1]
                else
                  @client_number = row['from_number'][3..-1]
                end
              else
                @client_number = row['from_number'].gsub('^', '')
              end
              if row['to_number'].include?("+")
                if row['to_number'].include?("^")
                  @telerivet_number = row['to_number'][4..-1]
                else
                  @telerivet_number = row['to_number'][3..-1]
                end
              else
                @telerivet_number = row['to_number'].gsub('^', '')
              end
              logger.info "<------#{@telerivet_number}--------->"
              @conversation_number = current_admin_user.conversations.where("phone_number = ? AND final_from_number = ?", @client_number, @telerivet_number)
              if @conversation_number.count == 0
                @conversation = current_admin_user.conversations.create(:phone_number => @client_number, :msg_time => DateTime.parse(row['created_at']).change(:offset => "+0800"), :msg_des => row['message_description'], :unread_count => 0, :final_from_number => @telerivet_number)
                logger.info "-------------------<#{@conversation.inspect}------->"
              else
                if @conversation_number.first.msg_time < DateTime.parse(row['created_at']).change(:offset => "+0800")
                  @converation = @conversation_number.first.update(:msg_time => DateTime.parse(row['created_at']).change(:offset => "+0800"),:msg_des => row['message_description'] )
                # else
                #   @converation = @conversation_number.update(:total_count => @conversation_number.total_count + 1)
                end
              end
            end
          elsif row['direction'].downcase == "outgoing"
            if row['to_number'].include?("+")
              if row['to_number'].include?("^")
                @client_number = row['to_number'][4..-1]
              else
                @client_number = row['to_number'][3..-1]
              end
            else
              @client_number = row['to_number'].gsub('^', '')
            end

            if row['from_number'].include?("+")
              if row['from_number'].include?("^")
                @telerivet_number = row['from_number'][4..-1]
              else
                @telerivet_number = row['from_number'][3..-1]
              end
            else
              @telerivet_number = row['from_number'].gsub('^', '')
            end
              
            @conversation_number = current_admin_user.conversations.where("phone_number = ? AND final_from_number = ?",@client_number, @telerivet_number)
            if @conversation_number.count == 0
              @conversation = current_admin_user.conversations.create(:phone_number => @client_number, :msg_time => DateTime.parse(row['created_at']).change(:offset => "+0800"), :msg_des => row['message_description'], :unread_count => 0, :final_from_number => @telerivet_number)
            else
              if @conversation_number.first.msg_time < DateTime.parse(row['created_at']).change(:offset => "+0800")
                @converation = @conversation_number.first.update(:msg_time => DateTime.parse(row['created_at']).change(:offset => "+0800"),:msg_des => row['message_description'])
              # else
              #   @converation = @conversation_number.update(:total_count => @conversation_number.total_count + 1)
              end
            end
          end
        end
      end
      @messages = current_admin_user.messages.import(columns, values, validate: true)
    end
    if @messages.num_inserts == 0
      redirect_to manage_setting_path, :alert => "All records are duplicate."
    else
      if @duplicate == 0
        @notice = "<h4>Import successfully<br/></h4><p>#{@fresh.to_s} Records added."
      else
        @notice = "<h4>Import successfully<br/></h4><p>#{@fresh} Records added.<br/>#{@duplicate} Duplicate records found."
      end
      redirect_to manage_setting_path, :notice => @notice
    end
  end

  def remove_all
    @messages = current_admin_user.messages
    if @messages.count > 0
      Message.where(:coordinator_id => current_admin_user).delete_all
      flash[:notice] = "All messages have been deleted."
      redirect_to manage_setting_path
    else
      redirect_to manage_setting_path
    end
  end
  

  private
    def set_telerivet
      # @telerivet = ApiSetting.first
      @telerivet = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
      logger.info"<=======#{@telerivet.inspect}==========>"
      @api_key = @telerivet.telerivet_api_key
      @project_id = @telerivet.telerivet_project_id
      @phone_id = @telerivet.telerivet_phone_id
      @web_hook_secret = @telerivet.webhook_api_secret
    end

    def message_params
      params.require(:message).permit(:to_number, :message_description, :unique_message_id, :phone_id, :contact_id, :direction, :status, :project_id, :message_type, :source, :time_created, :from_number, :starred, :coordinator_id) rescue {}
    end
    def set_message
      @message = Message.unscoped.find(params[:id])
      authorize @message
    end
    def telerivet_api_url
      "https://api.telerivet.com/v1"
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

class Test
  def get_name_from_number(number, p_arr_contact)
    p_arr_contact.each do |p|
      if number.include?(p[1])
        return p[0]
      elsif p[1].include?(number)
        return p[0]
      end
    end
    return number
  end

  def calculateLastTimeMessage(time)
    f_time = Time.at(time)
    return f_time.strftime("%I:%M %P")
  end
end