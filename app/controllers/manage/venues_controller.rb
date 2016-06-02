class Manage::VenuesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_venue, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Venues", :manage_venues_path
  before_action :check_user_permission, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  def index
    @venues = policy_scope(Venue).filter(params)
    authorize @venues
    render :layout => "setting_data"
    add_breadcrumb "Home", :root_path
  end

  def show
  end

  def new
    @venue = Venue.new
    authorize @venue
  end

  def edit
  end

  def create
    @venue = Venue.new(:name => params[:title])
    @venue.save
    authorize @venue
    render :text => @venue
  end

  # PATCH/PUT /product_categories/1
  def update
    @venue = Venue.find(params[:id])
    @name = params[:title]
    @venue.update_attributes(:name => @name)
    render :text => @venue
  end

  # DELETE /product_categories/1
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy
    redirect_to manage_venues_path
    # render json: { }, status: :ok
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_venue
    @venue = Venue.unscoped.find(params[:id])
    authorize @venue
  end

  # Only allow a trusted parameter "white list" through.
  def venue_params
    params.require(:venue).permit(:name) rescue {}
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