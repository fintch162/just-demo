class Manage::AgeGroupsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_age_group, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  # respond_to :js ,:only =>[ :update ]
  
  def create
    @age_group = AgeGroup.new(:title => params[:title])
    @age_group.save
    authorize @age_group
    render :text => @age_group
  end

  # PATCH/PUT /product_categories/1
  def update
    @age_group = AgeGroup.find(params[:id])
    @title = params[:title]
    @age_group.update_attributes(:title => @title)
    render :text => @age_group
  end

  # DELETE /product_categories/1
  def destroy
    @age_group = AgeGroup.find(params[:id])
    @age_group.destroy
    render json: { }, status: :ok
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_age_group
    @age_group = AgeGroup.unscoped.find(params[:id])
    authorize @age_group
  end

  # Only allow a trusted parameter "white list" through.
  def level_params
    params.require(:age_group).permit(:title) rescue {}
  end
end