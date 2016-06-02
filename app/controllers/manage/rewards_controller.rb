class Manage::RewardsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_filter :find_reward, only: [:show, :edit, :update, :destroy]
  
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Rewards", :manage_rewards_path

  respond_to :html, :json


  def index
    @reward = Reward.new
    @rewards = Reward.all
  end

  def new
    @reward = Reward.new
  end

  def create
    @reward = Reward.new(reward_params)
    if @reward.save
      redirect_to manage_rewards_path
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def find_instructor
    instructor = params[:instructor]
    if !instructor.blank?
      @instructor = Instructor.find_by_id(instructor.to_i)
      @jobs = @instructor.jobs
      respond_to :js
    end
  end

  private
    def find_reward
      @model = Reward.find(params[:id]) if params[:id]
    end
    def reward_params
      params.require(:reward).permit(:instructor_id, :points, :job_id, :reward_description) rescue {}
    end
end