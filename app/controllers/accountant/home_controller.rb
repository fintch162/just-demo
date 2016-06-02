class Accountant::HomeController < Accountant::BaseController
  include ApplicationHelper
  before_action :user_accountant_permission, except: [:index]

  def index
    if !current_admin_user.nil? && !current_admin_user.accountant?
      user_accountant_permission
    end
  end

  def payments
    @manual_payments = ManualPayment.all
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: AccountantPaymentDatatable.new(view_context) 
      }
    end
  end

  def reports
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: AccountantReportsDatatable.new(view_context) 
      }
    end
  end
end