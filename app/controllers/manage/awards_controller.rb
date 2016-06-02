class Manage::AwardsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :get_award, :only => [ :edit, :update ]

  def index
    @award = Award.new
    @awards = Award.order("position")
  end

  def new
    @award = Award.new
  end


  def edit
  end

  def create
    @award = Award.new(award_params)

    if @award.save
      redirect_to manage_awards_path
    end 
  end

  def update
    respond_to do |format|
      if @award.update(award_params)
        format.html { redirect_to manage_awards_path, notice: 'Award was successfully updated.' }
        format.json { render :show, status: :ok, location: @award }
      else
        format.html { render :edit }
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end    
  end

  def sort
    @awards = Award.all
    params[:award].each_with_index do |id, index|
      @awards.where(:id => id).each do |p|
        p.update position: index+1
      end
    end
    render nothing: true
  end

  private
    def award_params
      params.require(:award).permit(:name, :desciption, :image, :position, :short_name) rescue {}
    end

    def get_award
      @award = Award.find(params[:id])
    end
end