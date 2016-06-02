class Api::V1::AgeGroupsController < ApplicationController
	before_action :check_authentication_token 
	def index
		@age_groups = AgeGroup.all.order(:title)
		render :status => 200,
           :json => { :success => true,
                      :age_groups => @age_groups
                    }

  end
end