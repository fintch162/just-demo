class Manage::GroupClassesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_filter :set_default_order, only: :index
  before_action :set_group_class, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs, except: [:group_class_beta]
  respond_to :html, :json
  add_breadcrumb "Home", :manage_root_path
  before_action :check_user_permission, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :group_classes_search ]

  def index
    # @group_classes = policy_scope(GroupClass).preloaded.limit(5)#.filter(params)
  end

  def show
    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @group_class = current_admin_user.group_classes.new
    authorize(@group_class)
  end

  def edit
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def create
    @group_class = current_admin_user.group_classes.new(group_class_params)
    filter_group_class
    @group_class.save!
    if params[:fromInstAjax]
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js
        format.html do
          if @group_class.valid?
            redirect_to manage_group_classes_path
          else
            render "new"
          end
        end
      end  
    end  
  end

  # PATCH/PUT /product_categories/1
  def update
    @group_class.update(group_class_params)
    @group_class.update_attributes(:updated_at => Time.now)
    filter_group_class
    respond_to do |format|
      format.html do
        if @group_class.valid?
          redirect_to manage_group_classes_path
        else
          render "edit"
        end
      end
      format.js
      format.json do
        if @group_class.valid?
          render json: { status: 202 }
        else
          render json: {}, status:  422
        end
      end
    end
  end

  # DELETE /product_categories/1
  def destroy
    @group_class.update is_deleted: true

    # @group_class.destroy
    # authorize(@group_class)
    # respond_with [:manage, @group_class]
    respond_to do |format|
      format.js
      format.html do
        redirect_to params[:returnInstructorPage].present? ? manage_instructor_path(params[:returnInstructorPage]) : manage_group_classes_path
      end
    end 
  end

  def destroy_from_edit
    @group_class = GroupClass.find(params[:id])
    @group_class.update is_deleted: true
    flash[:notice] = 'class has been deleted.'
    redirect_to edit_manage_group_class_path(@group_class)
  end

  def search_classes_instructor_wise
    @instructor = Instructor.find_by_id(params[:selectedInstructor])
    @instructor_gp = @instructor.group_classes.order('day asc, time asc')
    respond_to do |format|
      format.js
    end 
  end

  def group_classes_search
    filter_group_class
    respond_to do |format|
      format.js
    end
  end

  def add_new_class
    respond_to do |format|
      format.js
    end
  end

  def apply_group_class_detail_to_job
    @group_class = GroupClass.find(params[:group_class])
    @job = Job.find(params[:job])

    feetype = FeeType.find(@group_class.fee_type_id)
    if feetype.name.downcase == "per course"
      lessonCount = @group_class.lesson_count
    else
      lessonCount = @job.lesson_count
    end
    feeTotal = @group_class.fee

    @job.update day_of_week: @group_class.day, class_time: @group_class.time, duration: @group_class.duration,
                fee_type_id: @group_class.fee_type_id, fee_total: feeTotal, instructor_id: @group_class.instructor_id,
                lesson_count: lessonCount, group_class_id: @group_class.id, applied_date: Time.now, is_apply_class: true

    render json: @job
  end

  def remove_group_class_detail_from_job
    @job = Job.find(params[:job])
    @job.update day_of_week: nil, class_time: nil, duration: nil,
                fee_type_id: nil, fee_total: nil, instructor_id: nil,
                lesson_count: nil, group_class_id: nil, applied_date: nil, is_apply_class: false
    render json: @job
  end

  def group_class_beta
    add_breadcrumb "Group Class Beta", :manage_group_class_beta_path
  end

  def group_class_beta_search
    @instructors = []
    @age_groups = []
    @venues = []
    filter_group_class 
    if params[:under].present?
      str = ''
      cnt = 0

      if params[:venue].present? && params[:ven] == 'false'
        str = "venue_id = "+params[:venue]
        cnt = 1
      end
      if params[:age_group].present? && params[:age] == 'false'
        if cnt != 0
          str = str + "AND age_group_id = " + params[:age_group]
        else
          str = "age_group_id = "+ params[:age_group]
        end
        cnt = 2
      end
      if params[:instructor].present? && params[:inst] == 'false'
        if cnt != 0
          str = str + "AND instructor_id = " + params[:instructor]
        else
          str = "instructor_id = "+ params[:instructor]
        end
      end
      logger.info "<-----String------#{str}--------------->"
      @group_class = GroupClass.where(str).where(is_deleted: false)
      if params[:inst] == 'true'
        @instructors = Instructor.where('id IN (?)',@group_class.pluck('instructor_id').uniq).order(:name)
      end
      if params[:age] == 'true'
        @age_groups = AgeGroup.where('id IN (?)',@group_class.pluck('age_group_id').uniq)
      end
      logger.info"<-----#{params[:ven]}--#{params[:inst]}---->"
      if params[:ven] == 'true'
        @venues = Venue.where('id IN (?)',@group_class.pluck('venue_id').uniq)
      end
      # @instructors = Instructor.where('id IN (?)',@group_class.pluck('instructor_id').uniq).order(:name)    
    else
      if !params[:instructor].present?
        @instructors = Instructor.where('id IN (?)',@group_classes.pluck('instructor_id').uniq).order(:name)
      end
      if !params[:age_group].present?
        @age_groups = AgeGroup.where('id IN (?)',@group_classes.pluck('age_group_id').uniq)
      end
      if !params[:venue].present?
        @venues = Venue.where('id IN (?)',@group_classes.pluck('venue_id').uniq)
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def group_class_info
    @group_class = GroupClass.find(params[:id])
  end

  def gorup_classes_by_venue
    @instructors = []
    @group_classes = []
    if params[:venue].present? && params[:venue] != ''
      filter_group_class
      if params[:instructor].present?
        @instructors = Instructor.where('id IN (?)',GroupClass.where(is_deleted: false).where(venue_id: params[:venue]).pluck('instructor_id'))
      else
        @instructors = Instructor.where('id IN (?)',@group_classes.where(is_deleted: false).pluck('instructor_id').uniq).order(:name)
      end
    end
  end

  def change_booking_status
    @group_class = GroupClass.find(params[:id])
    @group_class.update_attributes(booking_status: params[:booking_status],booking_status_time: Time.now)
  end

  def book_group_class
    @group_class = GroupClass.find(params[:id])
    @job = Job.new
    @job.students.build
  end

  

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_group_class
    @group_class = GroupClass.find(params[:id])
    authorize(@group_class)
  end

  # Only allow a trusted parameter "white list" through.
  def group_class_params
    params.require(:group_class).permit(:slot_vacancy, :slot_maximum, :day, :time, :fee_type, :duration,
                                        :level_id, :instructor_id, :venue_id, :age_group_id, :class_type_id,
                                        :lesson_count, :remarks, :fee, :admin_user_id, :fee_type_id) rescue {}
  end

  def set_default_order
    params[:sort] ||= {}
    params[:sort][:dir] ||= "asc"
    params[:sort][:field] ||= "day, time"
  end
  
  def filter_group_class
    day = params[:day]
    venue = params[:venue]
    instructor = params[:instructor]
    age_group = params[:age_group]
      
    @all = [day, venue, instructor, age_group]
    @filed = ['day', 'venue_id', 'instructor_id', 'age_group_id']
    @filed_val = []

    str = ""
    spliter = ""
    # str = @filed[0] + " = ? and "  + @filed[1] + " = ? and " + @filed[2] + " = ? and " + @filed[3] + " = ? "
    if day.present?
      str += @filed[0] + " = ? " 
       @filed_val << @all[0]
       spliter = "and "
    end
    if venue.present?
      str += spliter + @filed[1] + " = ?  "
      @filed_val << @all[1]
       spliter = "and "
    end
    if instructor.present?
      str += spliter + @filed[2] + " = ? "
      @filed_val << @all[2]
       spliter = "and "
    end
    if age_group.present?
      str += spliter + @filed[3] + " = ? "
      @filed_val << @all[3]
    end
    if @filed_val.length == 4
      @group_classes = GroupClass.where(str, @filed_val[0],@filed_val[1], @filed_val[2], @filed_val[3]).where(is_deleted: false).order('day asc,time asc')
    elsif @filed_val.length == 3
      @group_classes = GroupClass.where(str, @filed_val[0],@filed_val[1], @filed_val[2]).where(is_deleted: false).order('day asc,time asc')
    elsif @filed_val.length == 2
      @group_classes = GroupClass.where(str, @filed_val[0],@filed_val[1]).where(is_deleted: false).order('day asc,time asc')
    elsif @filed_val.length == 1
      @group_classes = GroupClass.where(str, @filed_val[0]).where(is_deleted: false).order('day asc,time asc')
    else
      @group_classes = GroupClass.where(is_deleted: false).order('day asc,time asc').all
    end
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
  def add_breadcrumbs
    add_breadcrumb "Group class list", :manage_group_classes_path
  end
end