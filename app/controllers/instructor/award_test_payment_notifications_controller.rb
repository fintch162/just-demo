class Instructor::AwardTestPaymentNotificationsController < Instructor::BaseController
  before_action :check_user_permission
  
  def index
    # @award_test_payment_notifications = current_admin_user.award_test_payment_notifications.includes(:award_test,:instructor_student).where(status: "Paid")
    respond_to do |format|
      format.html { }
      format.json { 
        render json: InstAwardTestNotificationDatatable.new(view_context) 
      }
 	 end
  end

end
