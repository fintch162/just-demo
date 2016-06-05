class Api::V1::IdentityCardsController < ApplicationController
	before_action :check_authentication_token 

	def show
		@identitycard = IdentityCard.find(params[:id])
		render json: @identitycard
	end
end