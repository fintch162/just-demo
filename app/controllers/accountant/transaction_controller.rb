class Accountant::TransactionController < Accountant::BaseController
	include ApplicationHelper
  	before_action :user_accountant_permission

  	def coordinator
      respond_to do |format|
        format.html { render layout: "setting_data" }
        format.json { 
          render json: AccountantCoordinatorDatatable.new(view_context) 
        }
      end
  	end

  	def instructor_fee
  		respond_to do |format|
	      format.html { render layout: "setting_data" }
	      format.json { 
	        render json: AccountantInstructorFeeDatatable.new(view_context) 
	      }
    	end
  	end

  	def instructor_test
      respond_to do |format|
        format.html { render layout: "setting_data" }
        format.json { 
          render json: AccountantInstructorTestDatatable.new(view_context) 
        }
      end 
  	end
end