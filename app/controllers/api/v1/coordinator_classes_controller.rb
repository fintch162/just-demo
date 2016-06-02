class Api::V1::CoordinatorClassesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :check_authentication_token

  before_action :set_coordinator_class, only: [:show, :update, :destroy] 
  def index
    coordinator_classes = CoordinatorClass.all.order("created_at DESC")
    render json: coordinator_classes.to_json(:include => [:venue, :instructor, :age_group,:fee_type] )
  end

  def create
    @coorinator = Coordinator.find_by(authentication_token: params[:authentication_token])
    @coordinator_class = @coorinator.coordinator_classes.new(coordinator_class_params)
    if @coordinator_class.save
     render json: @coordinator_class.to_json(:include => [:venue, :instructor, :age_group,:fee_type]), status: 200
    else
      render json: { message: @coordinator_class.errors.first.join(' ') },status: 401
    end
  end

  def update
    if @coordinator_class.update(coordinator_class_params)
      render json: @coordinator_class.to_json(:include => [:venue, :instructor, :age_group,:fee_type]),status: 200 
    else
      render json: { message: @coordinator_class.errors.first.join(' ') },status: 401
    end
  end

  def destroy
    @coordinator_class.destroy
    render json: { message: "Deleted successfully" }, status: 200
  end

  def show
    coordinator_classes = CoordinatorClass.find(params[:id])
    render json: coordinator_classes.to_json(:include => [:venue,:instructor,:age_group,:fee_type])
  end

  def filter
    @coordinator_classes = CoordinatorClass.where(venue_id: params[:venue_id],age_group_id: params[:age_id]).order("day asc,time asc")
    day_sort
    render json: @all_days_arr.to_json(:include=>[:venue,:instructor,:age_group,:fee_type])
  end


  def instructor_filter
    @coordinator_classes = CoordinatorClass.where(instructor_id: params[:id]).order("day asc,time asc")
    day_sort
    render json: @all_days_arr.to_json(:include=>[:venue,:instructor,:age_group,:fee_type])
  end

  # def day_sort_instructor
  #   days_arry = []
  #   @all_days_arr = [] 
  #   @coordinator_classes.order('day asc,time asc').each do |gp_class| 
  #     if gp_class.day.to_i == 0 
  #       days_arry << gp_class 
  #     else 
  #       @all_days_arr << gp_class 
  #     end 
  #   end
  #   @all_days_arr = @all_days_arr + days_arry
  # end

  def day_sort
    days_arry = []
    @all_days_arr = [] 
    @coordinator_classes.order('day asc,time asc').group_by(&:day).each do |day,gp_class| 
      if day.to_i == 0 
        days_arry << {:day => day, :gp_class => gp_class }
      else 
        @all_days_arr <<  {:day => day, :gp_class => gp_class}
      end 
    end
    @all_days_arr = @all_days_arr + days_arry
  end

  private

  	def coordinator_class_params
      params.permit(:day, :venue_id, :instructor_id, :age_group_id, :coordinator_id, :duration, :time, :notes, :fee_type_id,:amount)
    end

    def set_coordinator_class
      begin
        @coordinator_class = CoordinatorClass.find(params[:id])
      rescue Exception => e
        render json: { error: I18n.t("coordinator_classes.not_found"), status: 404 }
      end
    end
end
