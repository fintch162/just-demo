class Instructor::InstructorMessagesController < Instructor::BaseController
  include InstructorStudentsHelper
  respond_to :js, only: [ :send_student_a_link ]
  before_action :set_telerivet,:check_user_permission
  
  def index
    if @inst_conversations != "Disconnected"
      @inst_conversations = current_admin_user.instructor_conversations.paginate(:page => params[:page], :per_page => 20).order('msg_time DESC')
    end
  end

  def unread_conversations
    if @inst_conversations != "Disconnected"
      @inst_conversations = current_admin_user.instructor_conversations.where('unread_count > ?', 0).paginate(:page => params[:page], :per_page => 20).order('msg_time DESC')
      respond_to :js
    end
  end

  def inst_incoming_messages
    if @inst_conversations != "Disconnected"
      @inst_messages = current_admin_user.instructor_messages.where(direction: ['Incoming','incoming']).paginate(:page => params[:page], :per_page => 20).order('time_created DESC')
      @message_direction = "incoming"
      # .pluck('instructor_conversation_id').uniq
      # @inst_conversations = InstructorConversation.where(id: @inst_messages).paginate(:page => params[:page], :per_page => 20).order('msg_time DESC')
    end
    respond_to do |format|
      format.js {}
      format.html {}
    end
  end

  def inst_outgoing_messages
    if @inst_conversations != "Disconnected"
      @inst_messages = current_admin_user.instructor_messages.where(direction: ['Outgoing','outgoing']).paginate(:page => params[:page], :per_page => 20).order('time_created DESC')
      @message_direction = "outgoing"
    end
    if params[:bulk_id].present?
      @inst_messages = @inst_messages.where(bulk_sms_id: params[:bulk_id])
    end
      @inst_messages.paginate(:page => params[:page])
      respond_to do |format|
        format.js {}
        format.html {}
      end
  end

  def inst_conversation_messages
    if @inst_conversations != "Disconnected"
      @inst_conversation_messages = InstructorMessage.where(instructor_conversation_id: params[:id]).order('time_created desc')
      InstructorConversation.find(params[:id]).update(unread_count: 0)
    end
  end

  def inst_send_message
    if @inst_conversations != "Disconnected"  
      to_number = params[:to_number]
      content = params[:message_body]
      
      uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      http.ca_file = "#{Rails.root}/certificate/cacert.pem"

      if @phone_id.blank?
        http.start {
          @req = Net::HTTP::Post.new(uri.path)
          @req.form_data = {
            "content" => content.html_safe,
            "to_number" => to_number,
            "status_url" => request.base_url.to_s + "/inst_sms_notification",
            # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
            "status_secret" => @web_hook_secret
          }
        }
      else
        http.start {
          @req = Net::HTTP::Post.new(uri.path)
          @req.form_data = {
            "phone_id" => @phone_id,
            "content" => content.html_safe,
            "to_number" => to_number,
            "status_url" => request.base_url.to_s + "/inst_sms_notification",
            # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
            "status_secret" => @web_hook_secret
          }
        }
      end
        @req.basic_auth @instructor_telerivet_api_key, ''    
        res = JSON.parse(http.request(@req).body)
        to_number = res["to_number"]
        @response = res
      @message = "Message sent successfully."
      if !@response['error']
        make_entry_in_message_and_conversation
      end
      if params[:conversation_id].present?
        redirect_to instructor_conversation_path(params[:conversation_id])
      else
        redirect_to instructor_instructor_messages_path
      end
    end
  end

  def set_sms_unread
    @inst_message = InstructorMessage.find(params[:id])
    @inst_message.update(:message_status => "Unread")
    @inst_message.instructor_conversation.update(unread_count: @inst_message.instructor_conversation.unread_count + 1)
    render :nothing => true
  end

  def send_student_a_link                                              
    student = InstructorStudent.find_by_secret_token(params[:student])
    if current_admin_user.instructor?
      get_telerivet_key = current_admin_user.telerivet_api_key
    end
    to_number = params[:to_number]
    content = params[:message_body]
    
    @student_view_url = ApiSetting.first.student_view_url  
    if !@student_view_url.present?
      @student_view_url = request.base_url
    end
    @student_msg_path =  @student_view_url + "/student/" + student.secret_token
    content = content.gsub("<student_link>", @student_msg_path).gsub('<student_name>', student.student_name)

    uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.ca_file = "#{Rails.root}/certificate/cacert.pem"

    if @phone_id.blank?
      http.start {
        @req = Net::HTTP::Post.new(uri.path)
        @req.form_data = {
          "content" => content.html_safe,
          "to_number" => to_number,
          "status_url" => request.base_url.to_s + "/inst_sms_notification",
          "status_secret" => @web_hook_secret
        }
      }
    else
      http.start {
        @req = Net::HTTP::Post.new(uri.path)
        @req.form_data = {
          "phone_id" => @phone_id,
          "content" => content.html_safe,
          "to_number" => to_number,
          # "status_url" => request.base_url.to_s + "/inst_sms_notification",
          "status_secret" => @web_hook_secret
        }
      }
    end
      @req.basic_auth @instructor_telerivet_api_key, ''    
      res = JSON.parse(http.request(@req).body)
      to_number = res["to_number"]
      @response = res
    @message = "Message sent successfully."
    logger.info"<----response----------#{@response}---------------------->"
    if !@response['error']
      make_entry_in_message_and_conversation
    end
    @instructor_student = InstructorStudent.find(params[:inst_id])
    @instructor_student_contacts = @instructor_student.student_contacts.where.not(:contact => ["", nil])
    @inst_messages=InstructorConversation.where("instructor_id = (?) AND phone_number IN (?)" , current_admin_user,@instructor_student_contacts.pluck(:contact))
    logger.info"<-------------#{@inst_messages.inspect}--------------------->"     
  end

  def make_entry_in_message_and_conversation
    if !@response['to_number'].nil?
      format_phon_number #(instructor_students)helper called

      @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)

      @inst_conversation_number = current_admin_user.instructor_conversations.where("phone_number = ? AND from_number = ?", @client_number, @telerivet_number)

      if @inst_conversation_number.count == 0
        @inst_conversation = current_admin_user.instructor_conversations.create(:phone_number => @client_number, :msg_time => @time_created , :msg_des => @response['content'], :unread_count => 0, :from_number => @telerivet_number)
      else
        if @inst_conversation_number.first.msg_time < @time_created
          @inst_conversation = @inst_conversation_number.first.update(:msg_time => @time_created,:msg_des => @response['content'] )
          @inst_conversation = @inst_conversation_number.first
        end
      end

    end

    if params[:stundent_ids].present?
      @message = current_admin_user.instructor_messages.create(:to_number => @client_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @telerivet_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id, bulk_sms_id: @bulk_sms_id)
    else
      @message = current_admin_user.instructor_messages.create(:to_number => @client_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @telerivet_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id)
    end
  end

  def send_msg_preview
    @std_name_list = []
    @msg = params[:text_msg].to_s.html_safe
    #@msg_url = params[:student_view_url].to_s.html_safe
    @std_id = params[:stundent_ids]
    if params[:award_test_id].present?
      @award_test = AwardTest.find(params[:award_test_id])
    else
      @award_test = false
    end
    if params[:group_class].present?
      @group_ids = params[:group_class]
    else
      @group_ids = false
    end

    @sutdent_ids = params[:stundent_ids].split(',')
    @student = InstructorStudent.where("id IN (?)", @sutdent_ids)
    @bulk_sms_id = Time.now.to_i.to_s
  end

  def group_message
    @group_class = GroupClass.find(params[:group_class])
    @sutdent_ids = params[:stundent_ids].split(',')
    # @contact_number = []
    # @sutdent_ids.each do |std|
    #   begin
    #     @contact_number << InstructorStudent.find(std).student_contacts.where(:primary_contact => true).first.contact
    #   rescue
    #     @contact_number << nil
    #   end
    # end
    # @uniq_contact = @contact_number.uniq
    # @uniq_contact = @uniq_contact.compact
    # @msg = params[:text_msg]
    @std_name_list = []
    @sutdent_ids.each do |std_id|
      @std_obj = InstructorStudent.find(std_id)
      @student_msg_path = request.base_url + student_public_link_path(@std_obj.secret_token)
      @student_name = @std_obj.student_name
      @msg = params[:text_msg].gsub("<student_link>", @student_msg_path).gsub('<student_name>', @student_name)

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
      begin
        tr = Telerivet::API.new(@instructor_telerivet_api_key)
        @project = tr.get_project_by_id(@project_id)
        if !@contact_number.nil? || @contact_number != ""
          if @phone_id.blank?
            @p = @project.send_messages({
                'content' => @msg, 
                'to_numbers' => @contact_number
            })
          else
            @p = @project.send_messages({
                'phone_id' => @phone_id,
                'content' => @msg, 
                'to_numbers' => @contact_number
            })
          end
          #if params[:isReqXhr] == "true"
          #   respond_to :js
          #else
          #   redirect_to instructor_group_award_message_path(@awaard_ids)
          #end
        else
          if params[:isReqXhr] == "true"
            @alert = "Phonenumber cant be blank"
            #respond_to :js
          else
            #redirect_to instructor_group_award_message_path(@awaard_ids), :alert => "Phonenumber cant be blank"
          end
        end
      rescue Exception => e
        @error = "Telerivet server down or phone is not responding or check your API setting"
      end
    end
  end

  def group_award_message
    @sutdent_ids = params[:stundent_ids].split(',')
    if params[:group_class].present?
      @group_class = params[:group_class]
    else
      @group_class = false
    end
    if params[:award_test_id].present?
      @awaard_ids = params[:award_test_id]
      @award_test = AwardTest.find(@awaard_ids)
    else
      @awaard_ids = false
    end
    if params[:bulk_sms_id].present?
      @bulk_sms_id = params[:bulk_sms_id]
    else
      @bulk_sms_id = false
    end
    if @inst_conversations != "Disconnected"
      InstructorMessage.group_award_message_model(current_admin_user,@sutdent_ids,params[:text_msg],@award_test,@bulk_sms_id,@group_class)
    end
  end
  
  # def group_award_message1
  #   @sutdent_ids = params[:stundent_ids].split(',')
  #   if params[:group_class].present?
  #     @group_class = params[:group_class]
  #   else
  #     @group_class = false
  #   end
  #   if params[:award_test_id].present?
  #     @awaard_ids = params[:award_test_id]
  #     @award_test = AwardTest.find(@awaard_ids)
  #   else
  #     @awaard_ids = false
  #   end
  #   # @award_ids = Award.find(params[:award_id])
  #   # @contact_number = []
  #   # @sutdent_ids.each do |std|
  #   #   begin
  #   #     @contact_number << InstructorStudent.find(std).student_contacts.where(:primary_contact => true).first.contact
  #     # rescue
  #     #   @contact_number << nil
  #     # end
  #   # end
  #   # @uniq_contact = @contact_number.uniq
  #   # @uniq_contact = @uniq_contact.compact
  #   @std_name_list = []
    
  #   @bulk_sms_id = Time.now.to_i.to_s
    
  #   @sutdent_ids.each do |std_id|
  #     @std_obj = InstructorStudent.find(std_id)
  #     @student_msg_path = 'http://app.swimsafer.com.sg/student/' + @std_obj.secret_token
  #     @student_name = @std_obj.student_name
  #     @msg = params[:text_msg].gsub("<student_link>", @student_msg_path).gsub('<student_name>', @student_name)
  #     if @award_test
  #       @msg = @msg.gsub('<award_name>', @award_test.award.name).gsub('<award_date>', @award_test.test_date.strftime("%e %b %Y")).gsub('<award_time>', @award_test.test_time.strftime("%I:%M%P")).gsub('<award_venue>', Venue.find(@award_test.venue_id).name)
  #     end
  #     if @std_obj.student_contacts.present?
  #       if @std_obj.student_contacts.where(:primary_contact => true).present? 
  #         @contact_number = @std_obj.student_contacts.where(:primary_contact => true).first.contact
  #        else
  #         @contact_number = @std_obj.student_contacts.first.contact
  #       end
  #     else
  #       @contact_number = ""
  #     end
  #     @std_name_list << @std_obj.student_name
  #     begin
  #       uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")
  #       http = Net::HTTP.new(uri.host, uri.port)
  #       http.use_ssl = true
  #       http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  #       http.ca_file = "#{Rails.root}/certificate/cacert.pem"
  #       if !@contact_number.nil? || @contact_number != ""
  #         if @phone_id.blank?
  #           http.start {
  #             @req = Net::HTTP::Post.new(uri.path)
  #             @req.form_data = {
  #             "content" => @msg,
  #             "to_number" => @contact_number,
  #             "status_url" => request.base_url.to_s + "/inst_sms_notification",
  #             # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
  #             "status_secret" => @web_hook_secret
  #             }
  #           }
  #         else
  #           http.start {
  #             @req = Net::HTTP::Post.new(uri.path)
  #             @req.form_data = {
  #               "phone_id" => @phone_id,
  #               "content" => @msg,
  #               "to_number" => @contact_number,
  #               "status_url" => request.base_url.to_s + "/inst_sms_notification",
  #               # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
  #               "status_secret" => @web_hook_secret
  #             }
  #           }
  #         end
  #         @req.basic_auth @instructor_telerivet_api_key, ''    
  #         res = JSON.parse(http.request(@req).body)
  #         to_number = res["to_number"]
  #         @response = res
  #         @message = "Message sent successfully."
  #         if !@response['error']
  #           make_entry_in_message_and_conversation
  #         end
  #         # if params[:isReqXhr] == "true"
  #         #   respond_to :js
  #         # else
  #         #   redirect_to instructor_group_award_message_path(@awaard_ids)
  #         # end
  #       else
  #         if params[:isReqXhr] == "true"
  #           @alert = "Phonenumber cant be blank"
  #         #  respond_to :js
  #         else
  #          # redirect_to instructor_group_award_message_path(@awaard_ids), :alert => "Phonenumber cant be blank"
  #         end

  #       end

  #     rescue Exception => e
  #       @error = "Telerivet server down or phone is not responding or check your API setting"
  #     end
  #   end
  # end
  # handle_asynchronously :group_award_message

  def check_for_message_telerivet_sms_settings
  end

  private
    def set_telerivet
      @instructor_telerivet_api_key = current_admin_user.telerivet_api_key
      @project_id = current_admin_user.instructor_telerivet_project_id
      @phone_id = current_admin_user.instructor_telerivet_phone_id
      @web_hook_secret = current_admin_user.instructor_webhook_api_secret
      if @instructor_telerivet_api_key == "" || @project_id == "" || @phone_id == "" || @web_hook_secret == "" ||  @instructor_telerivet_api_key.nil? || @project_id.nil? || @phone_id.nil? || @web_hook_secret.nil?
        @inst_conversations = "Disconnected"
      end
    end

    def telerivet_api_url
      "https://api.telerivet.com/v1"
    end

end