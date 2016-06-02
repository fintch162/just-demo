class Instructor::SynchronizeContactsController < Instructor::BaseController
  before_action :check_user_permission
  before_action :check_token_expiry, except: [:index, :google_oauth2, :google_oauth2_fail]
  # before_action :refresh_access_token, only: [:update_contact_on_google]

  def index
    if !session[:access_token]
      refresh_access_token
    end
    @instructor_students = current_admin_user.instructor_students.where(is_deleted: false).order('student_name')
  end

  def google_oauth2
    if current_admin_user.google_synch_email
      if current_admin_user.google_synch_email == request.env['omniauth.auth'].info.email
        match_gmail = true
      else
        match_gmail = false
        flash[:alert] = "please login with " + current_admin_user.google_synch_email
      end
    else
      current_admin_user.update(google_synch_email: request.env['omniauth.auth'].info.email)
      match_gmail = true
    end
    if match_gmail
      session[:google_email]=request.env['omniauth.auth'].info.email
      session[:access_token] = request.env["omniauth.auth"].credentials.token
      if request.env["omniauth.auth"].credentials.refresh_token?
        # session[:refresh_token] = request.env["omniauth.auth"].credentials.refresh_token
        current_admin_user.update(google_refresh_token: request.env["omniauth.auth"].credentials.refresh_token)
      end
        session[:expire_at] = Time.at(request.env["omniauth.auth"].credentials.expires_at)
      flash[:notice] = "you are login with  " + session[:google_email] +" , now you can synch contacts. "
    end
    # redirect_to instructor_synchronize_contacts_path
    redirect_to instructor_profile_path(tab: 'gc')
  end

  def synchronize_contact
    @student = InstructorStudent.find(params[:id])
      if !@token_expire
        generate_xml 
        sync_contact_to_gmail
      end

      respond_to do |format|
        format.js{}
        format.html{ redirect_to instructor_instructor_students_path }
      end
  end
  
  def synchronize_contacts
    student_ids = params[:student_ids].split(',')
    @count = 0
    @instructor_students = current_admin_user.instructor_students.where(google_contact_id: nil).where(is_deleted: false).where('id IN (?)',student_ids)#.limit(20)
    @instructor_students.each do |student|
      @student = student
      generate_xml
      break if @error
      sync_contact_to_gmail
      @count += 1
    end
    flash[:notice] = @count.to_s + " contacts synchronized." if !@error
    respond_to do |format|
      format.js 
      format.html {redirect_to instructor_synchronize_contacts_list_path}
    end
  end

  def automatically_synchronize_contacts
    logger.info"<-----------------------automatically_synchronize_contacts--------------------------------->"
    @instructor_students = current_admin_user.instructor_students.where(google_contact_id: nil).where(is_deleted: false)
    logger.info"<--------------------#{@instructor_students.count}--------------------------------->"
    if @instructor_students.count > 0
      @student = @instructor_students.first
      generate_xml
      # break if @error
      sync_contact_to_gmail
      respond_to do |format|
        format.js 
        format.html {redirect_to instructor_profile_path(tab: 'gc')}
      end
    else
      redirect_to instructor_profile_path(tab: 'gc')
    end
  end

  def generate_xml
    @student_contacts = @student.student_contacts
    if !current_admin_user.contacts_prefix.nil?
      @prefix = current_admin_user.contacts_prefix
    else
      @prefix = ''
    end
    if @student.group_classes.count == 0
      @prefix ? @prefix = "Ex " + @prefix : ''
    else
      @group_class = @student.group_classes.last
      @prefix += ' ' + Date::DAYNAMES[@group_class.day][0..2] + ' ' + @group_class.time.strftime("%l:%M%P") 
    end
    @prefix ? @prefix += " " : @prefix = ''
    if @student.student_contacts.count > 0 
      @body = '<?xml version="1.0" encoding="UTF-8"?>
<entry>
<category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/contact/2008#contact"/>
<title>'+ @prefix + @student.student_name+'</title>
<gd:name>
<gd:fullName>'+ @prefix + @student.student_name+'</gd:fullName>
</gd:name>' 
        @student_contacts.each do |contact|
          if contact.contact != ''
            contact.relationship && contact.relationship != '' ? @rel = contact.relationship : @rel = 'Null'
            if @rel == "Myself"
              @body = @body + '<gd:phoneNumber rel="http://schemas.google.com/g/2005#mobile" primary="true">'+contact.contact+'</gd:phoneNumber>'
            elsif @rel == "Other"
              @body = @body + '<gd:phoneNumber rel="http://schemas.google.com/g/2005#other">'+contact.contact+'</gd:phoneNumber>'
            else
              @body = @body + '<gd:phoneNumber label="'+ @rel +'">'+contact.contact+'</gd:phoneNumber>'
            end
          end
        end
        @body = @body +'<gContact:groupMembershipInfo deleted="false" href="http://www.google.com/m8/feeds/groups/'+session[:google_email]+'/base/6"/>
</entry>'
    end
  end
  
  def sync_contact_to_gmail
    @error = false
    @google_contact_id = ''
    url = URI("https://www.google.com/m8/feeds/contacts/#{session[:google_email]}/full?access_token=#{session[:access_token]}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["gdata-version"] = '3.0'
    request["content-type"] = 'application/atom+xml'
    request.body = @body

    response = http.request(request)
    @response_xml = response.read_body
    @response_hash = Nokogiri.XML(@response_xml)
    @response_hash = Hash.from_xml(@response_hash.to_s)
    if @response_hash.keys[0] == 'errors'
      flash[:alert] = @count.to_s + 'contacts are synchronized but error occured while synchronize ' + @student.student_name
      @error = true
    elsif @response_hash.keys[0] == 'entry'
      @response_hash['entry'].each do |key,value|
        if key == 'id'
          contact_id = value.split('/')
          @google_contact_id = contact_id.last
          if @google_contact_id && @google_contact_id != ''
            @student.update(google_contact_id: @google_contact_id,is_update: false)
          end
        end
      end
    end
  end

  def remove_synchronized_contacts
    if !session[:access_token]
      redirect_to '/auth/google_oauth2' and return
    end
    @count = 0
    if params[:id].present?
      @student = InstructorStudent.find(params[:id])
      get_etag
      remove_contact_from_gmail if @etag && !@error
    else
      @students = current_admin_user.instructor_students.where('google_contact_id IS NOT null').where.not(google_contact_id: '').order('student_name')#.limit(20)
      @students.each do |student|
        @student = student
        get_etag
        remove_contact_from_gmail if @etag && !@error
        break if @error
      end
      flash[:notice] = @count.to_s + ' contacts are removed successfully.' if @count > 0
    end
    if params[:disconnect].present?
      current_admin_user.update(google_synch_email: nil, google_refresh_token: nil)
      session.delete(:access_token)
      flash[:notice] = "successfully unliked your Google account" if !flash[:notice]
    end
    respond_to do |format|
      format.js {}
      if params[:disconnect].present?
        format.html { redirect_to instructor_profile_path(tab: 'gc_synk')}#params[:disconnect].present? ? instructor_profile_path : redirect_to instructor_synchronize_contacts_list_path}
      else
        format.html { redirect_to instructor_synchronize_contacts_list_path }
      end
    end
    # redirect_to instructor_synchronize_contacts_list_path
  end


  def get_etag
    @error = false
    @etag = nil
    # contact_id = current_admin_user.instructor_students.where('google_contact_id IS NOT null').where.not(google_contact_id: '').first.google_contact_id
    contact_id = @student.google_contact_id
    url = URI("https://www.google.com/m8/feeds/contacts/#{session[:google_email]}/full/#{contact_id}?access_token=#{session[:access_token]}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["gdata-version"] = '3.0'
    request["content-type"] = 'application/atom+xml'

    response = http.request(request)
    @response_xml = response.read_body
    @response_hash = Nokogiri.XML(@response_xml)
    @response_hash = Hash.from_xml(@response_hash.to_s)
    if @response_hash.keys[0] == 'errors'
      @response_hash['errors']['error'].each do |key,value|
        if key == 'code' && value == 'notFound'
          update_student
          return
        end
      end
      flash[:alert] = @student.student_name + ' contact is not found on your Google account ' 
      @error = true
    elsif @response_hash.keys[0] == 'entry'
      @response_hash['entry'].each do |key,value|
        if key == 'gd:etag'
          @etag = value
        end
      end
    end
  end

  def remove_contact_from_gmail
    contact_id = @student.google_contact_id
    url = URI("https://www.google.com/m8/feeds/contacts/#{session[:google_email]}/full/#{contact_id}?access_token=#{session[:access_token]}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Delete.new(url)
    request["gdata-version"] = '3.0'
    request["content-type"] = 'application/atom+xml'
    request["If-Match"] = @etag

    response = http.request(request)
    @response_xml = response.read_body
    
    if @response_xml != ''
      @error = true
      flash[:alert] = 'Error occured while removing '+ @student.student_name
    else
      update_student
    end
  end

  def update_student
    @student.update(google_contact_id: nil,is_update: false)
    @count += 1
  end

  def update_contact_on_google
    @student=InstructorStudent.find(params[:id])
    if !@token_expire
      if @student.google_contact_id && @student.google_contact_id != ''
        get_etag
        if !@error
          generate_xml
          update_google_contact
        end
      end
    end
    if !request.xhr?
      redirect_to instructor_instructor_student_path(@student)
    else
      render nothing: true
    end
    #instructor_update_google_contact_path
  end

  def update_google_contact
    contact_id = @student.google_contact_id
    url = URI("https://www.google.com/m8/feeds/contacts/#{session[:google_email]}/full/#{contact_id}?access_token=#{session[:access_token]}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(url)
    request["gdata-version"] = '3.0'
    request["content-type"] = 'application/atom+xml'
    request["If-Match"] = @etag
    request.body = @body

    response = http.request(request)
    @response_xml = response.read_body
  end

  def google_oauth2_fail
    flash[:alert] = "Google authorization failed."
    redirect_to root_path
  end

  def refresh_access_token
    if current_admin_user.google_refresh_token && current_admin_user.google_synch_email
      refresh_token = current_admin_user.google_refresh_token
      #'1/6IBvxmBj8h6y7WvXqPYM6DBtwRBMsDZ7-cFLbNWK_Vw'
      url = URI("https://www.googleapis.com/oauth2/v3/token?client_secret=#{ApiSetting.first.google_client_secret}&grant_type=refresh_token&refresh_token=#{refresh_token}&client_id=#{ApiSetting.first.google_client_id}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["gdata-version"] = '3.0'
      request["content-type"] = 'application/x-www-form-urlencoded'

      response = http.request(request)
      @response = response.read_body
      @response = @response.gsub(/[{}\n' '"']/,'').split(',').map{|h| h1,h2 = h.split(':'); {h1 => h2}}.reduce(:merge)
      if @response['access_token']
        session[:access_token] = @response['access_token']
        session[:expire_at] = Time.now + 3500.seconds
        session[:google_email] = current_admin_user.google_synch_email
      elsif @response['error']
        current_admin_user.update(google_refresh_token: nil)
        flash[:alert] = "Something went wrong, please login again to gmail account."
        redirect_to instructor_synchronize_contacts_list_path
        if @response['error'] == 'invalid_grant'
        end
      end
    end
  end

  def update_student_contacts_after_login
    @instructor_students = current_admin_user.instructor_students.where(is_update: true)
    @instructor_students.each do |student|
      @student=student
      if !@token_expire
        generate_xml
        if @student.google_contact_id?
          get_etag
          if !@error
            update_google_contact
          end
        else
          sync_contact_to_gmail
        end
      end
      @student.update(is_update: false)
    end
    redirect_to instructor_root_path
  end

  private
    def check_token_expiry
      if session[:access_token]
        if session[:expire_at]
          if session[:expire_at] < Time.now
            if current_admin_user.google_refresh_token
              refresh_access_token
            else
              @token_expire = true
              flash[:alert] = "your google login session has been expire so please login again "
              session.delete(:access_token)
            end
          end
        end
      else
        if current_admin_user.google_refresh_token
          refresh_access_token
        else
          redirect_to '/auth/google_oauth2' and return
        end
      end
    end
end