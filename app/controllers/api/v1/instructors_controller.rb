class Api::V1::InstructorsController < ApplicationController
	before_action :check_authentication_token
  skip_before_filter :verify_authenticity_token, only: [ :update ]

	def index
		@instructors = Instructor.all.order(:name)
		render :status => 200,
           :json => { :success => true,
                      :instructors => @instructors
                    }

  end
  def show
    @instructor = Instructor.find(params[:id])
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :user => @instructor,
                      :type => @instructor.type,
                      :profile_picture => @instructor.profile_picture.url
                    }
  end

  def update
    @instructor = @user
    if params["file"]
      params[:instructor] = {}
      params[:instructor][:profile_picture] = params["file"]
    end
    if params["instructor"][:birthday]
      params["instructor"][:birthday] = instructor_params[:birthday].to_time
    end
    @instructor.update_attributes(instructor_params)
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :user => @instructor,
                      :type =>@instructor.type,
                      :profile_picture => @instructor.profile_picture.url
                    }
  end

  private

  def instructor_params
    params.require(:instructor).permit(:profile_picture,:email,:birthday,:instructor_name,:password)
  end
end