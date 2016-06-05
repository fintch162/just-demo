class Api::V1::VenusController < ApplicationController
	before_action :check_authentication_token 
	def index
		@venus = Venue.all.order(:name)
		render :status => 200,
           :json => { :success => true,
                      :venus => @venus
                    }
  

  end

  def show
    @venu = Venue.find(params[:id])
    render :status => 200,
           :json => { :success => true,
                      :venus => @venu
                    }
  end

  def venue_count
    @venue_count = []
    Venue.all.order(:name).each do |v|
      venue = v
      count =  CoordinatorClass.where(age_group_id: params[:id],venue_id: v.id).count;
      @venue_count << {count: count , venus: venue} if count > 0
    end
    render json: @venue_count
  end


end