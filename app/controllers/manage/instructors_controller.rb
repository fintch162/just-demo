class Manage::InstructorsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_instructor, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json, :js
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Instuctor list", :manage_instructors_path
  before_action :check_user_permission, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]


  def index
    # @instructors = policy_scope(Instructor).filter(params)
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: InstructorsDatatable.new(view_context) }
    end
  end

  def show
    begin
      @jobs = Job.where(instructor_id: @instructor.id, job_status: "Receipt")
      @jobs_refered_total = @jobs.pluck(:referral).compact.inject(0,:+)
      @jobs_taken = @jobs.count
      @students_taken = 0
      @jobs.each do |job|
        @students_taken += job.students.count
      end
      @active_students = 0
      @instructor.instructor_students.each do |instructor_student|
        if instructor_student.group_classes.count != 0 
          @active_students = @active_students + 1
        end
      end
      session[:instructor_id] = @instructor.id
      @group_classes = @instructor.group_classes.order(day: :asc , time: :asc).where.not(is_deleted: true)

      add_breadcrumb @instructor.name, manage_instructor_path(@instructor)
      respond_to do |format|
        format.html { render layout: "setting_data" }
      end
    rescue Exception => e
      logger.info "-------------------------------- #{e} ----------------------------------"
    end
    
  end

  def new
    @instructor = Instructor.new
    @identity_card = IdentityCard.all
    @instructor.instructor_identities.build
    @status = ["Active", "Inactive"]
    authorize(@instructor)
  end

  def edit
    if @instructor.instructor_identities.count == 0
      @instructor.instructor_identities.build
    end
    @status = ["Active", "Inactive"]
    add_breadcrumb "Instuctor " + @instructor.name, :edit_manage_instructor_path
    @identity_card = IdentityCard.all
  end
  
  def create
    params["instructor"]["birthday"] = params["instructor"]["birthday"].to_time
    @instructor = Instructor.new(instructor_params)
    authorize(@instructor)
    @instructor.save
    # respond_with :manage, @instructor
    redirect_to manage_instructors_path
  end

  # PATCH/PUT /product_categories/1
  def update
    logger.info"------------#{params["instructor"]["birthday"]}------------------------"
    # exit
    params["instructor"]["birthday"] = params["instructor"]["birthday"].to_time
    @status = ["Active", "Inactive"]
    if instructor_params[:password].blank?
      instructor_params.delete("password")
      instructor_params.delete("password_confirmation")
    end
    @instructor.update(instructor_params)
    @identity_card = IdentityCard.all
    respond_to do |format|
      format.html do
        if @instructor.valid?
          redirect_to manage_instructors_path
        else
          render "edit"
        end
      end
      format.json do
        if @instructor.valid?
          render json: { status: 202 }
        else
          render json: {}, status:  422
        end
      end
    end
  end

  # DELETE /product_categories/1
  def destroy
    @instructor.destroy
    authorize(@instructor)
    respond_with :manage, @instructor
  end

  def instructor_job_taken
    @instructor = Instructor.find(params[:id])
    add_breadcrumb @instructor.name, manage_instructor_path(@instructor)
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: InstructorJobTakenDatatable.new(view_context) }
    end
  end
  def unlock_edit_mode
    @instructor = Instructor.find(params[:id])
    @instructor.update is_enable_edit: true
  end

  def lock_edit_mode
    @instructor = Instructor.find(params[:id])
    @instructor.update is_enable_edit: false
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_instructor
    @instructor = Instructor.find(params[:id])
    authorize(@instructor)
  end

  # Only allow a trusted parameter "white list" through.
  def instructor_params
    params.require(:instructor).permit!
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