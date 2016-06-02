class Manage::BaseController < ActionController::Base
  layout "manage"
  # before_filter :authenticate_admin_user!
  before_filter :set_cache_buster

  rescue_from ActiveRecord::RecordNotFound do
    render(:template => '/manage/base/record_not_found', :layout => 'manage', :status => :not_found)
  end
  # rescue_from ActionController::RoutingError, :with => :render_404
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :complete_payment_alert, :sms_count
  def pundit_user
    current_admin_user
  end

  
  private


    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
    def instructor_take_job
      @take_job_count = InstructorJobApplication.where(:coordinator_view => false).count
    end

    def sms_count
    	if admin_user_signed_in?
        @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(current_admin_user.id)
    	  if !@coordinator_api_setting.nil?  
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
    	      @conversations = Conversation.where("final_from_number LIKE ?", "#{telerivet_phone_number}").order("msg_time DESC").where.not(unread_count: 0).count
    	    else
    	      @conversations = 0
    	    end
        else
          @conversations = 0
        end
      end
	  end

    def complete_payment_alert
      status = ["Paid", "paid"]
      @payment_notifications = PaymentNotification.where("status IN (?)",  status).order('id desc').limit(10)
      @manual_local_id= ManualPayment.where.not(:local_payment_id=> nil).where.not(:local_payment_id=> '').pluck("local_payment_id").uniq
      # @payment_notifications_cnt = PaymentNotification.where("status IN (?)",  status)
      @payment_notifications_cnt=PaymentNotification.where("id NOT IN (?)",@manual_local_id).where(:status=>"Paid")
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
end

module ActiveAdmin::Devise::Controller
  def create
    self.resource = warden.authenticate!(auth_options)
    if params[:admin_user][:remember_me].to_s == "1"
      userId = self.resource.id.to_s
      cookies[:remember_me_id] = { :value => userId, :expires => 30.days.from_now }
      userCode = Digest::SHA1.hexdigest(self.resource.email)[4,18]
      cookies[:remember_me_pass] = {:value => params[:admin_user][:password],  :expires => 10.days.from_now}
      cookies[:remember_me_code] = {:value =>userCode, :expires => 10.days.from_now}
    else  
      cookies.delete :remember_me_pass
      cookies.delete :remember_me_code
      cookies.delete :remember_me_id  
    end  
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    session[:user_id] = self.resource.id 
   
    if !session[:return_to].blank?
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
    # params[:user].merge!(remember_me: 1)
    
  end

  def after_sign_in_path_for(resource)
    #if resource.instructor? || resource.coordinator?
    if resource.instructor?
      "/instructor"
    elsif resource.coordinator?
      "/manage"
    elsif resource.accountant?
      "/accountant"
    else
      admin_dashboard_path
    end
  end

  def after_sign_out_path_for(resource)
    url = URI(request.referer).path
    if url.include?("manage")
      "/manage"
    else
      "/manage"
    end
  end
end