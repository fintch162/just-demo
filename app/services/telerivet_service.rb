class TelerivetService

	def initialize(params)
		@params = params
	end

	def create(request)
		set_telerivet
		telerivat_data
		telerivat_call(request)
		return @response
	end

  private
  	def telerivat_call(request)
  		telerivet_api_url
		uri = URI("#{telerivet_api_url}/projects/#{@project_id}/messages/outgoing")
  		puts"-----Service---#{@to_number}-----#{@content}--------#{telerivet_api_url}----#{request}-----"
	    http = Net::HTTP.new(uri.host, uri.port)
	    http.use_ssl = true
	    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

	    http.ca_file = "#{Rails.root}/certificate/cacert.pem"
	    http.start {
	      req = Net::HTTP::Post.new(uri.path)
	      req.form_data = {
	        "content" => @content,
	        "phone_id" => @phone_id,
	        "to_number" => @to_number,
	        # "status_url" => "http://pinkynbrain.com/sms_notification",
	        "status_url" => request +"/sms_notification",
	        "status_secret" => @web_hook_secret
	      }
	      req.basic_auth @api_key, ''    
	      res = JSON.parse(http.request(req).body)
	      to_number = res["to_number"]
	      @response = res
	    }
  	end


  	def telerivat_data
  		@to_number = @params[:toNumber]
	    @content = @params[:message_description]
  	end

		def telerivet_api_url
	    "https://api.telerivet.com/v1"
	  end

	  def set_telerivet
	    userId = @params[:userId]
	    @telerivet = CoordinatorApiSetting.find_by_coordinator_id(userId)
	    @api_key = @telerivet.telerivet_api_key
	    @project_id = @telerivet.telerivet_project_id
	    @phone_id = @telerivet.telerivet_phone_id
     	@web_hook_secret = @telerivet.webhook_api_secret
	  end

end