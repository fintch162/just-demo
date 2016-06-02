class Manage::CoordinatorController <  Manage::BaseController
	include ApplicationHelper
  	before_action :user_manage_permission
	before_action :set_coordinator, only: [:edit, :update]
	#before_action :check_user_permission, only: [ :edit ,:update]

	def edit		
	end

	def update
		@coordinator.update(coordinator_params)
		sign_in @coordinator, :bypass => true
		redirect_to manage_setting_path     
	end

	private
	def set_coordinator
    @coordinator = Coordinator.find(params[:id])
  end

	def coordinator_params
		params.require(:coordinator).permit!		
	end

	def check_user_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      end
    else
      redirect_to manage_root_path
    end
  end
end
  