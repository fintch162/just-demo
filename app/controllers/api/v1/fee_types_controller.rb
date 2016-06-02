class Api::V1::FeeTypesController < ApplicationController
	before_action :check_authentication_token 
	def index
		@fee_types = FeeType.all
		render :status => 200,
           :json => { :success => true,
                      :fee_types => @fee_types
                    }

  end
end