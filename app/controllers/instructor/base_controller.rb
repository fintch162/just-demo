class Instructor::BaseController < ActionController::Base
  layout "account"
  # before_filter :authenticate_admin_user!

  # rescue_from ActiveRecord::RecordNotFound do
  #   render(:template => '/instructor/base/record_not_found', :layout => 'manage', :status => :not_found)
  # end

  include Pundit

  rescue_from Pundit::NotAuthorizedError, :with=> :user_not_authorized

  def pundit_user
    current_admin_user
  end

  private
    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
    
    def check_user_permission
      if admin_user_signed_in?
        if current_admin_user.coordinator?
          redirect_to manage_root_path
        elsif current_admin_user.admin?
          redirect_to admin_root_path
        elsif current_admin_user.accountant?
          redirect_to accountant_root_path
        end
      else
        redirect_to manage_root_path
      end
    end
end

module ActiveAdmin::Devise::Controller
  def after_sign_in_path_for(resource)
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
    if url.include?("instructor")
      "/instructor"
    else
      "/manage"
    end
  end
end