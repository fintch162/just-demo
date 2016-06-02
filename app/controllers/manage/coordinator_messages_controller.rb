class Manage::CoordinatorMessagesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_telerivet
  
  def send_student_a_link_manage
    @sutdent_ids = params[:stundent_ids].split(',')
    if !@sutdent_ids.blank?
      @contact_number = []
      @sutdent_ids.each do |std|
        begin
          @contact_number << InstructorStudent.find(std).student_contacts.where(:primary_contact => true).first.contact
        rescue
          @contact_number << nil
        end
      end

      @uniq_contact = @contact_number.uniq
      @uniq_contact = @uniq_contact.compact
      @msg = params[:text_msg]

      tr = Telerivet::API.new(@telerivet_api_key)
      @project = tr.get_project_by_id(@project_id)

      if @phone_id.blank?
        @project.send_messages({
          'content' => @msg, 
          'to_numbers' => @uniq_contact
        })
      else
        @m =  @project.send_messages({
          'phone_id' => @phone_id,
          'content' => @msg, 
          'to_numbers' => @uniq_contact
        })
      end
      redirect_to manage_award_test_path(params[:award_test].to_i), :notice => "Message sent successfully."
    else
      redirect_to manage_award_test_path(params[:award_test].to_i), :notice => "Contact number cant be blank."
    end
  end
  
  def send_msg_preview_manage
    @std_name_list = []
    @msg = params[:text_msg].to_s.html_safe
    # @msg_url = params[:student_view_url].to_s.html_safe
    @std_id = params[:stundent_ids]
    #@award_id = params[:awaard_id]
    @award_test = AwardTest.find(params[:award_test_id])
    @sutdent_ids = params[:stundent_ids].split(',')
    @student = InstructorStudent.where("id IN (?)", @sutdent_ids)
  end
  
  def group_award_message_manage
    @sutdent_ids = params[:stundent_ids].split(',')
    @awaard_ids = params[:awaard_id]
    @std_name_list = []
    @bulk_sms_id=Time.now.to_i.to_s
    @sutdent_ids.each do |std_id|
      @std_obj = InstructorStudent.find(std_id)
      @student_msg_path = 'http://app.swimsafer.com.sg/student/' + @std_obj.secret_token
      @student_name = @std_obj.student_name
      
      @award_test = AwardTest.find(params[:awaard_id])
      @award_name = @award_test.award.name
      @award_date = @award_test.test_date.strftime("%-d %b %Y")
      @award_time = @award_test.test_time.strftime("%-I:%M%P")
      @award_venue = Venue.find(@award_test.venue_id).name      
      
      @msg = params[:text_msg].gsub("<student_link>", @student_msg_path).gsub('<student_name>', @student_name).gsub('<award_name>', @award_name).gsub('<award_date>', @award_date).gsub('<award_time>', @award_time).gsub('<award_venue>', @award_venue)
      
      if @std_obj.student_contacts.present?
        if @std_obj.student_contacts.where(:primary_contact => true).present? 
          @contact_number = @std_obj.student_contacts.where(:primary_contact => true).first.contact
         else
          @contact_number = @std_obj.student_contacts.first.contact
        end
      else
        @contact_number = ""
      end
      @std_name_list << @std_obj.student_name
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      http.ca_file = "#{Rails.root}/certificate/cacert.pem"
      begin
        if !@contact_number.nil? || @contact_number != ""
          if @phone_id.blank?
            http.start {
              @req = Net::HTTP::Post.new(uri.path)
              @req.form_data = {
                "content" => @msg,
                "to_number" => @contact_number,
                "status_url" => request.base_url.to_s + "/sms_notification",
                # "status_url" => "http://pinkynbrain.com" + "/sms_notification",
                "status_secret" => @web_hook_secret
            }
          }
          else
            http.start {
              @req = Net::HTTP::Post.new(uri.path)
              @req.form_data = {
                "content" => @msg,
                'phone_id' => @phone_id,
                "to_number" => @contact_number,
                "status_url" => request.base_url.to_s + "/sms_notification",
                # "status_url" => "http://pinkynbrain.com" + "/sms_notification",
                "status_secret" => @web_hook_secret
            }
          }
          end
          @req.basic_auth @telerivet_api_key, ''    
          res = JSON.parse(http.request(@req).body)
          to_number = res["to_number"]
          @response = res
          logger.info "<----------#{!@response['error']}------->"
          if !@response['error']  
            @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)
            @message = current_admin_user.messages.create(:to_number => @response['to_number'], :message_description => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :contact_id => @response['contact_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @response['from_number'], :starred => @response['starred'], :bulk_sms_id=>@bulk_sms_id)
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
            # redirect_to manage_conversation_message_path(@message.to_number), notice: 'SMS sent'
            redirect_to manage_award_test_path(params[:id]), notice: 'SMS sent'
          else
            @message = @response
            respond_to do |format|
              format.js
            end
          end 

          # if params[:isReqXhr] == "true"
          #   respond_to :js
          # else
          #   redirect_to instructor_group_award_message_path(@awaard_ids)
          # end
        else
          if params[:isReqXhr] == "true"
            @alert = "Phonenumber cant be blank"
          #  respond_to :js
          else
           # redirect_to instructor_group_award_message_path(@awaard_ids), :alert => "Phonenumber cant be blank"
          end
        end
      rescue Exception => e
        logger.info "<-------#{e}--------------->"
        @error = "Telerivet server down or phone is not responding or check your API setting"
      end
    end
  end

  def search
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    if current_admin_user.is_account_activated?
      telerivet_phone_number = @coordinator_api_setting.telerivet_phone_number
      direction = ["incoming", "Incoming", "Outgoing", "outgoing"]
      # @conversations = Conversation.where("final_from_number = ?", telerivet_phone_number).where("LOWER(msg_des) LIKE :search or phone_number LIKE :search", search: "%#{params[:search].downcase}%").order("msg_time DESC").paginate(:page => params[:page], :per_page => 20)
      @conversations = Message.where(:coordinator_id => current_admin_user.id).where("direction IN (?)", direction).where("to_number LIKE ? OR from_number LIKE ?", "%#{@coordinator_api_setting.telerivet_phone_number}%", "%#{@coordinator_api_setting.telerivet_phone_number}%").where("LOWER(message_description) LIKE :search or to_number LIKE :search or from_number LIKE :search", search: "%#{params[:search].downcase}%").order("time_created DESC").paginate(:page => params[:page], :per_page => 20)
    else
      @conversations = "Disconnected"
    end
    @conversationsCnt = Conversation.where("final_from_number LIKE ?", "#{telerivet_phone_number}").order("msg_time DESC").where.not(unread_count: 0).count
  end

 def unread_messages

 end
  private
    def set_telerivet
      @api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
      @telerivet_api_key = @api_setting.telerivet_api_key
      @project_id = @api_setting.telerivet_project_id
      @phone_id = @api_setting.telerivet_phone_id
      @web_hook_secret = @api_setting.webhook_api_secret
    end

    def telerivet_api_url
      "https://api.telerivet.com/v1"
    end
end