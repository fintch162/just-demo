class Manage::LevelsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_level, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  # respond_to :js ,:only =>[:update]
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Group Classes list", :manage_group_classes_path
  before_action :check_user_permission, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]

  def index
    @levels = policy_scope(Level).filter(params)
    @age_groups = policy_scope(AgeGroup).filter(params)
    authorize @levels
    render :layout => "setting_data"
  end

  def show
  end

  def new
    @level = Level.new
    authorize @level
  end

  def edit

  end

  def create
    @level = Level.new(:title => params[:title])
    @level.save
    authorize @level
    render :text => @level
  end

  # PATCH/PUT /product_categories/1
  def update
    @level = Level.find(params[:id])
    @title = params[:title]
    @level.update_attributes(:title => @title)
    render :text => @level
  end

  # DELETE /product_categories/1
  def destroy
    @level = Level.find(params[:id])
    @level.destroy
    render json: { }, status: :ok
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_level
    @level = Level.unscoped.find(params[:id])
    authorize @level
  end

  # Only allow a trusted parameter "white list" through.
  def level_params
    params.require(:level).permit(:title) rescue {}
  end
  def check_user_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      end
    else
      redirect_to manage_root_path
    end
  end
end