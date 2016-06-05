class Api::V1::LogoutController < ApplicationController
  def logout
    @mobile_device = MobileDevice.find_by_device_registration_id(params[:deviceRegistartionId])
    @adminuser = @mobile_device.update(:status => "Pending")
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
end