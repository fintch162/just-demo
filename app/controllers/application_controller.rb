class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_admin_user
  def authenticate_admin_user
    if !devise_controller?
      if (params[:controller] != "welcome" && params[:action] != "view_pa") && (params[:controller] != "welcome" && params[:action] == "success") && (params[:controller] != "welcome" && params[:action] == "get_invoice") && (params[:controller] != "payment_notifications" && params[:action] != "create")
        if admin_user_signed_in?
          if current_admin_user.coordinator?
            redirect_to manage_root_path
          elsif current_admin_user.instructor?
            redirect_to instructor_root_path
          elsif current_admin_user.accountant?
            redirect_to accountant_root_path
          end
        end
      end
    end
  end

  def render_404(exception = nil)
      if exception
        logger.info "Rendering 404: #{exception.message}"
      end
      render :file => "#{Rails.root}/public/routing_err.html", :status => 404, :layout => false
    end

  def check_authentication_token
    if params[:authentication_token]
      @user = AdminUser.find_by(authentication_token: params[:authentication_token])
      if @user
        @user.update last_activity: Time.zone.now
      else
        render :status => 401,
           :json => { 
                        :success => false,
                        :info => "Login & try again",
                        :data => {},
                        :rstatus => 0
                    }
      end
    else
      render :status => 401,
           :json => { 
                        :success => false,
                        :info => "Login & try again",
                        :data => {},
                        :rstatus => 0
                    }
       
    end
  end
end
