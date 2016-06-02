class Accountant::BaseController < ActionController::Base
  layout "manage"
  
  # before_filter :authenticate_admin_user!
  # before_filter :set_cache_buster

  rescue_from ActiveRecord::RecordNotFound do
    render(:template => '/manage/base/record_not_found', :layout => 'manage', :status => :not_found)
  end
  # rescue_from ActionController::RoutingError, :with => :render_404
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # before_action :complete_payment_alert, :sms_count
  def pundit_user
    current_admin_user
  end

  private
    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
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
    if url.include?("accountant")
      "/accountant"
    else
      "/accountant"
    end
  end

end