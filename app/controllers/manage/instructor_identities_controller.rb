class Manage::InstructorIdentitiesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_instructor_identity, only: [:show, :edit, :update, :destroy]
  def new
  end

  def create
    @instructor_identity = InstructorIdentity.new(instructor_identity_params)
    if @instructor_identity.save
      redirect_to edit_manage_instructor_path(@instructor_identity.instructor_id)
    else
      redirect_to edit_manage_instructor_path(@instructor_identity.instructor_id)
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @instructor = @instructor_identity.instructor
    @instructor_identity.destroy
    respond_to do |format|
      format.html do 
        redirect_to edit_manage_instructor_path(@instructor)
      end
    end
  end

  private
    def instructor_identity_params
      params.require(:instructor_identity).permit(:instructor_id, :identity_card_id, :expiry_date, :identity_image)
    end

    def set_instructor_identity
      @instructor_identity = InstructorIdentity.find(params[:id])
    end
end