class Api::V1::MobileDevicesController < ApplicationController
  def create
    @m = MobileDevice.create(:device_registration_id => params[:deviceRegistartionId], :status => "Pending")
    render :text => "Done"
  end

  def register_user_by_device_registration_id
    logger.info "========= Welcome : #{params} ========="
    exit
  end
end