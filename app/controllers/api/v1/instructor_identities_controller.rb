class Api::V1::InstructorIdentitiesController < ApplicationController

	before_action :check_authentication_token 
	skip_before_filter :verify_authenticity_token, only: [ :create,:update, :destroy]

	def index
		@userIdentities = @user.instructor_identities.order('created_at')
		if @userIdentities.present?
			@excludeIdentities = IdentityCard.all.where("Id NOT IN (?)",@userIdentities.pluck(:identity_card_id))
		else
			@excludeIdentities = IdentityCard.all
		end
		render json: {:includeCards => @userIdentities.to_json(:include =>[:identity_card]) , :excludeCards => @excludeIdentities.to_json}
	end

	def show
		@userIdentity = InstructorIdentity.find(params[:id])
		render json: {:image => @userIdentity.identity_image.url,:user => @userIdentity.to_json(:include =>[:identity_card])}
	end

	def create
		params[:identity_image] = params["file"]
		@user_identity = @user.instructor_identities.find_by_identity_card_id(params["identity_card_id"])
		if @user_identity 
			@user_identity.update_attributes(instructor_identity_params)
		else
			@userIdentity = @user.instructor_identities.new(instructor_identity_params)
			@userIdentity.save
		end
		render json: @userIdentity.to_json
	end

	def update
		if params["file"].present?
			params[:identity_image] = params["file"]
		end
		@userIdentity = InstructorIdentity.find(params[:id])
		@userIdentity.update_attributes(instructor_identity_params)
		@userIdentity = InstructorIdentity.find(params[:id])
		render json: @userIdentity.to_json
	end

	def destroy
		@userIdentity = InstructorIdentity.find(params[:id])
		@userIdentity.destroy
		render json: true
	end

	private
	def instructor_identity_params
		params.permit(:instructor_id,:identity_card_id,:expiry_date,:identity_image)
	end

end