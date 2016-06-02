class InstructorMessage < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :instructor_conversation
  belongs_to :group_class
  belongs_to :award_test

  def self.group_award_message_model(instructor,student_ids,msg_body,award_test,bulk_sms_id,group_class_id)
    @instructor = instructor
    self.set_telerivet
    @std_name_list = []
    student_ids.each do |std_id|
      @std_obj = InstructorStudent.find(std_id)
      @student_msg_path = 'http://app.swimsafer.com.sg/student/' + @std_obj.secret_token
      @student_name = @std_obj.student_name
      @msg = msg_body.gsub("<student_link>", @student_msg_path).gsub('<student_name>', @student_name)
      if award_test
        @msg = @msg.gsub('<award_name>', award_test.award.name).gsub('<award_date>', award_test.test_date.strftime("%e %b %Y")).gsub('<award_time>', award_test.test_time.strftime("%I:%M%P")).gsub('<award_venue>', Venue.find(award_test.venue_id).name)
      end
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
        uri = URI("https://api.telerivet.com/v1/projects/#{@project_id}/messages/outgoing")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = "#{Rails.root}/certificate/cacert.pem"
        if !@contact_number.nil? || @contact_number != ""
          if @phone_id.blank?
            http.start {
              @req = Net::HTTP::Post.new(uri.path)
              @req.form_data = {
              "content" => @msg,
              "to_number" => @contact_number,
              # "status_url" => request.base_url.to_s + "/inst_sms_notification",
              # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
              "status_url" => "http://app.singaporeswimming.com" + "/inst_sms_notification",
              "status_secret" => @web_hook_secret
              }
            }
          else
            http.start {
              @req = Net::HTTP::Post.new(uri.path)
              @req.form_data = {
                "phone_id" => @phone_id,
                "content" => @msg,
                "to_number" => @contact_number,
                # "status_url" => request.base_url.to_s + "/inst_sms_notification",
                # "status_url" => "http://pinkynbrain.com" + "/inst_sms_notification",
                "status_url" => "http://app.singaporeswimming.com" + "/inst_sms_notification",
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
            if !@response['to_number'].nil?
				      # format_phon_number #(instructor_students)helper called
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
				      #---------------------------------
				      @time_created = DateTime.parse(Time.zone.at(Time.strptime(@response['time_created'].to_s, "%s")).to_s)

				      @inst_conversation_number = @instructor.instructor_conversations.where("phone_number = ? AND from_number = ?", @client_number, @telerivet_number)

				      if @inst_conversation_number.count == 0
				        @inst_conversation = @instructor.instructor_conversations.create(:phone_number => @client_number, :msg_time => @time_created , :msg_des => @response['content'], :unread_count => 0, :from_number => @telerivet_number)
				      else
				        if @inst_conversation_number.first.msg_time < @time_created
				          @inst_conversation = @inst_conversation_number.first.update(:msg_time => @time_created,:msg_des => @response['content'] )
				          @inst_conversation = @inst_conversation_number.first
				        end
				      end

				    end

				    if bulk_sms_id
              if group_class_id
  				      @message = @instructor.instructor_messages.create(:to_number => @client_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @telerivet_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id, bulk_sms_id: bulk_sms_id,group_class_id: group_class_id)
  				    elsif award_test
                @message = @instructor.instructor_messages.create(:to_number => @client_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @telerivet_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id, bulk_sms_id: bulk_sms_id,award_test_id: award_test.id)
              end
            else
				      @message = @instructor.instructor_messages.create(:to_number => @client_number, :msg_des => @response['content'], :unique_message_id => @response['id'], :phone_id => @response['phone_id'], :direction => @response['direction'], :status => @response['status'], :project_id => @response['project_id'], :message_type => @response['message_type'], :source => @response['source'], :time_created => @time_created, :from_number => @telerivet_number, :starred => @response['starred'], instructor_conversation_id: @inst_conversation.id,group_class_id: group_class_id)
				    end
          end
        else
          # if params[:isReqXhr] == "true"
            @alert = "Phonenumber cant be blank"
          #  respond_to :js
          # else
           # redirect_to instructor_group_award_message_path(@awaard_ids), :alert => "Phonenumber cant be blank"
          # end

        end

      rescue Exception => e
        @error = "Telerivet server down or phone is not responding or check your API setting"
      end
    end
  end

  def self.set_telerivet
  	@instructor_telerivet_api_key = @instructor.telerivet_api_key
	  @project_id = @instructor.instructor_telerivet_project_id
	  @phone_id = @instructor.instructor_telerivet_phone_id
	  @web_hook_secret = @instructor.instructor_webhook_api_secret
  end
end
