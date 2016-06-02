class Manage::CannedResponsesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  def create
    if params[:canned_title].blank?
      @canned_res = CannedResponse.new(canned_response_params)
      if @canned_res.save
        redirect_to manage_message_templates_path
      end
    else
      @canned_response = CannedResponse.find(params[:canned_title])
      f = @canned_response.update(canned_response_params)
      respond_to do |format|
        format.html { redirect_to manage_message_templates_path }
      end
    end
  end

  def destroy
    @canned_response = CannedResponse.find(params[:id])
    @canned_response.destroy
    redirect_to manage_message_templates_path
  end
  
  def get_canned_tmp
    @canned_response = CannedResponse.find(params[:choosenTemplate])
    render :text => @canned_response.to_json
  end
  private
    def canned_response_params
      params.require(:canned_response).permit(:title, :description) rescue {}
    end
end