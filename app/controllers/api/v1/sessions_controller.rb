class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, only: :create_auth
  def create_auth
    user = AdminUser.authenticate(params[:email], params[:password])
    
     if user
      # if user.is_account_activated? 
      #   mobileDevice = MobileDevice.find_by_device_registration_id(params[:deviseId])
      #   if !mobileDevice.blank?
      #     coordinator = CoordinatorApiSetting.find_by_coordinator_id(user.id)
      #     mobileDevice.update(status: "Active", phoneNumber:  coordinator.telerivet_phone_number)
      #   end
      # end

      if user.authentication_token.blank?
        authToken = user.update authentication_token: generate_authentication_token
      end

      # render json: {user: user}

      render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :user => user,
                      :type => user.type,
                      :profile_picture => user.profile_picture.url
                    }
    else
      render :status => 401,
           :json => { 
                        :success => false,
                        :info => "Login Failed",
                        :data => {},
                        :rstatus => 0
                    }
    end
  end

  def destroy
    # expire auth token
      @user= User.where(:authentication_token=>params[:user][:authentication_token]).first
      @user.reset_authentication_token!
      render :status => 200,
        :json => { result: 
                    {
                      :success => true,
                      :info => "Logged out",
                      :data => {},
                      :rstatus => 1
                    }
                  }
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end
  private
    def generate_authentication_token
      Array.new(36){ rand(36).to_s(36) }.join
    end
end