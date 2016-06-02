class Instructor::HomeController < Instructor::BaseController
  require 'mechanize'
  require 'nokogiri'
  require 'open-uri'
  include InstructorStudentsHelper
  # before_action :check_user_log_in, except: [:get_registered_for_test]
  respond_to :js , only: [ :apply_for_job, :set_attended, :transfer_modal ]
  before_action :check_user_permission, only: [ :index, :new, :show, :update, :edit, 
                                                :create, :opportunity, :referrals, :apply_for_job, :dashboard]
  before_action :get_edit_fee_modal, :only => [:remove_fee, :edit_per_course_fee]
  before_action :check_hide_show_columns, only: [ :show, :sort_student, :group_class_view_add_more_months,:unpaid_fee_student,:group_class_view, :unregistered_students ]
  before_action :generate_month_according_current_month, only: [ :show, :sort_student, :group_class_view_add_more_months,:group_classes_deatil_print,:unpaid_fee_student,:group_class_view , :unregistered_students]
  before_action :mark_attendance, only: [:mark_present, :mark_absent, :remove_attendance]
  before_action :check_hide_show_columns_grp_cls_index, only: [:index]

  def dashboard
    @ins_student_count = current_admin_user.instructor_students.count
    @student_count = Student.where("job_id IN (?)",Job.where(:instructor_id => current_admin_user.id).where(:job_status => "Receipt").pluck(:id)).count
    # @student_count = @ins_student_count + @ins_job_student
    ## @student_ids = current_admin_user.instructor_students.pluck(:id)
    ## @fees =  Fee.where("instructor_student_id" => @student_ids)
    # Start: Total student and Current Month fee dispays on dashboard as activity for current logged in instructor
      @instructor_students = current_admin_user.instructor_students
      ##@active_students = 0
      ## @instructor_students.each do |instructor_student|
      ##   if instructor_student.group_classes.count != 0 
      ##     @active_students = @active_students + 1
      ##   end
      ## end
      @active_student_ids = current_admin_user.active_student_ids
      @active_student_count = @active_student_ids.count
      ## @instructor_student_ids = current_admin_user.instructor_students.ids
      ## @instructor_fee_collection = Fee.where(:instructor_student_id => @instructor_student_ids)
      @instructor_fee_collection = current_admin_user.fees
      @count_permonth_fee = 0
      @instructor_fee_collection.this_months_group_class_per_month_fee.each do |fee|
        @count_permonth_fee += fee.amount if fee.is_paid_include_past && fee.amount.present?
      end
      # @count_permonth_fee = @instructor_fee_collection.this_months_group_class_per_month_fee.where.not(payment_status: 'Due').sum(:amount)

      ## @count_permonth_fee = @count_permonth_fee.where.not(payment_status: 'Due').pluck(:amount).compact.inject(0,:+)

      instructor_student_ids = @instructor_students.ids
      @total_passed_student = InstructorStudentAward.where("instructor_student_id IN (?)", instructor_student_ids).where("LOWER(status) like ?", "pass")
      @total_passed_student = @total_passed_student.count
    #  End

    @transfer_in = current_admin_user.transfers.where('transfer_status IN (?)', ["Transferring", "Transferred"])
    # @day_list = current_admin_user.group_classes.pluck(:day).uniq
    # @group_classes = current_admin_user.group_classes
  
    # @transfer_out = Transfer.where('instructor_id = (?)', current_admin_user.id)
    @transfer_out = current_admin_user.transfers


    # For Notification
    @student_details=@instructor_students.order("updated_at desc").limit(10)
    # @instructor_students=InstructorStudent.where(admin_user_id: current_admin_user).pluck(:id)
    @instructor_students_awards=InstructorStudentAward.where("instructor_student_id IN (?) ", instructor_student_ids).where(:is_registered => true).order("updated_at desc").limit(10)

    @mearge_student_details_and_students_awards = (@instructor_students_awards + @student_details).sort_by(&:updated_at)
    
    @students_not_paid_curr_month=not_paid_student_count(0)
    @students_not_paid_prev_month=not_paid_student_count(-1)
    @students_not_paid_next_month=not_paid_student_count(1);

    ## @current_instructor_students= []
    ## current_admin_user.instructor_students.each do |m|
    ##   if m.group_classes.count > 0
    ##     @current_instructor_students << m.id
    ##   end
    ## end
    @award_for_pass_student=InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress = 'ready_for'  AND is_registered = false",@active_student_ids)
    logger.info"<----------------#{@award_for_pass_student.inspect}------------------------>"
    @award_count=@award_for_pass_student.group(:award_id).where(status: "Pass").count
    @ready_student_award_count=@award_for_pass_student.count
    @new_count = Array.new

    Award.all.order(:position).each do |award|
      @cnt = 0
      @award_count.each do |m|
        if m[0] == award.id
          @new_count.push(m)
          @cnt = 1
          break
        end
      end
      if (@cnt == 0)
        @new_count.push([award.id,0])
      end 
    end
    
    ## @pass_award = @award_for_pass_student.where(status: "Pass").pluck(:award_id).uniq
    ## @award= Award.where.not("id IN (?)",@pass_award)
    
    current_admin_user.feature_ids = Feature.ids  #for make entry in middle table for features
    
    # @award_for_pass_student.each do |award|
    #   logger.info"<----------------#{award.inspect}------------------------>"
    # end

  end

  def not_paid_student_count(fee_month)
    student_count=0
    fee_month=(Date.today + fee_month.month).at_beginning_of_month.strftime
    group_class_ids=current_admin_user.group_classes.where(fee_type_id:FeeType.per_month_id).ids
    group_class_ids.each do |group_class|
      inst_student_ids=GroupClass.find(group_class).instructor_students.ids
      inst_student_ids.each do |student|
        if Fee.where(monthly_detail:fee_month, instructor_student_id:student).count == 0
          student_count += 1
        end
      end
    end
    return student_count
  end

  def get_current_three_month
    @inst=InstructorStudent.where("Id IN (?)",current_admin_user.active_student_ids)
    @current_month=Date.today()
    @previous_one_month=(Date.today() - 1.month)
    @previous_two_month=(Date.today() - 2.month)
    @unpaid_fee_hash= Hash.new
    @total_month=[@current_month,@previous_one_month,@previous_two_month]
  end

  def index
    if admin_user_signed_in?
      session[:group_class_id] = ""
      @group_classes = current_admin_user.group_classes.order('day asc,time asc').where(is_deleted: false)
      @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.find_by_table_name("group_class")
      unless @add_or_more_less_months_saved_settings.blank?
        @startMonth = @add_or_more_less_months_saved_settings.start_month
        @endMonth = @add_or_more_less_months_saved_settings.end_month
      end

      if  !@hide_show_columns_grp_cls_index.age_group? || !@hide_show_columns_grp_cls_index.level? ||
          !@hide_show_columns_grp_cls_index.fee? || !@hide_show_columns_grp_cls_index.fee_type? ||
          !@hide_show_columns_grp_cls_index.students? || !@hide_show_columns_grp_cls_index.max_slot? ||
          !@hide_show_columns_grp_cls_index.vacancy? || !@hide_show_columns_grp_cls_index.venue?
          @isUnhideBtnShow = true
      end

      @unpaid_fee = 0
      get_current_three_month
      @total_month.each do |month|
        @unpaid_fee_hash["#{month}"] = []
        @inst.each do |inst_student|
          if inst_student.chek_current_month_fee(month).present?
            unless inst_student.chek_current_month_fee(month).is_paid
              @unpaid_fee_hash["#{month}"] << inst_student.id
              # @unpaid_fee += 1  
            end
          else
            @check_group_class=inst_student.group_classes.last.fee_type.name == "per month"
            if @check_group_class
              @unpaid_fee_hash["#{month}"] << inst_student.id
              # @unpaid_fee += 1
            end
          end
        end
      end
    end
  end

  def new
    #raise "asd"
    @group_class = GroupClass.new()
  end

  def edit
    @group_class = GroupClass.find(params[:id])
  end

  def create
    @group_class = current_admin_user.group_classes.new(group_class_params)
    @group_class.save!
    respond_to do |format|
      format.html do
        if @group_class.valid?
          redirect_to instructor_group_classes_index_path
        else
          render "new"
        end
      end
    end
  end

  def update
    @group_class = current_admin_user.group_classes.find(params[:id])
    @group_class.update_attributes(group_class_params)
    # redirect_to instructor_home_path(@group_class)
    redirect_to instructor_group_class_view_add_more_months_path(@group_class)
  end

  def show
    session[:group_class_id] = params[:id]
    @group_class = current_admin_user.group_classes.find(params[:id])
    @students_list = current_admin_user.group_classes.find(params[:id]).instructor_students.where(:group_id => nil)
    # @table_setting = TableSetting.where("table_name = (?) AND instuctor_id = (?)",  "group_class", current_admin_user.id)
    # logger.info "<-------------#{@table_setting}---------------->"
    # if @table_setting.count > 0
      
    # else
    # end
    # @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
  end

  def group_class_view
    logger.info"<----------------#{params}-------------------->"
    @is_attendace = ''
    @is_fees_check = ''
    session[:group_class_id] = params[:id]
    if params[:columnName].present? || params[:columnName] == ''
      @hide_show_column = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
      @hide_show_column.update(:name => false , :contact => false,:ic_number => false,:date_of_birth => false,:join_date => false,:description => false,:ready_for => false ,:training_for => false,:registered_for => false ,:achieved => false ,:profile_pic => false,:fee=>false,:student_id=>false)
      column_name = params[:columnName].gsub(/[-]/, '_').downcase
      column_name = column_name.gsub('profile_picture', 'profile_pic').gsub('joined_date','join_date')
      @hide_show_column = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
      if params[:columnName] != ''
        column_name_s = column_name.split(',')
        column_name_s.each do |c|
          @hide_show_column.update(c => true)
        end
      end

      if params[:columnTiming].present? || params[:columnTiming] != ''
        @hide_show_column.update(:timing=>params[:columnTiming])
      else
        @hide_show_column.update(:timing=>nil)
      end
      @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name("group_class")
      # @group_class = current_admin_user.group_classes.find(params[:id])

    else 
      @hide_show_column = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
      @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name("group_class")
      # @group_class = current_admin_user.group_classes.find(params[:id])
    end
  end

  def group_class_view_add_more_months
    group_class_view
    @group_class = current_admin_user.group_classes.find(params[:id])
    @students_list = @group_class.instructor_students.includes(:instructor_student_awards).includes(:student_contacts).includes(:fees).where(:group_id => nil)
    # @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    generate_fee_and_attendance_months
  end

  def unpaid_fee_student
    group_class_view
    @inst=InstructorStudent.where("Id IN (?)",current_admin_user.active_student_ids).includes(:fees)
    @inst_stu =[]
    @gp=[]
    if params[:month]
      @unpaid_fee = 0
      @inst.each do |inst_student|
        if inst_student.chek_current_month_fee(params[:month].to_date).present?
          unless inst_student.chek_current_month_fee(params[:month].to_date).is_paid
            @gp |= inst_student.group_classes.pluck(:id)
            @unpaid_fee += 1
            @inst_stu << inst_student.id
          end
        else
          @check_group_class=inst_student.group_classes.last.fee_type.name == "per month"
          if @check_group_class
            @gp |= inst_student.group_classes.pluck(:id)
            @unpaid_fee += 1
            @inst_stu << inst_student.id
          end
        end
      end
    elsif params[:timing_id]
      @inst.each do |inst_student|
        if !params[:time].blank?
          @time=('2000-01-01 00:'+params[:time])
          @student_timing=InstructorStudentTiming.where(instructor_student_id: inst_student.id,timing_id: params[:timing_id]).order(date: :asc, updated_at: :asc).last
          @inst_stu << @student_timing.instructor_student_id  if @student_timing.present? && @student_timing.time <= @time
          @gp |= inst_student.group_classes.pluck(:id) if @student_timing.present? && @student_timing.time <= @time
        else
          @student_timing=InstructorStudentTiming.where(instructor_student_id: inst_student.id,timing_id: params[:timing_id])
          @inst_stu |= @student_timing.pluck(:instructor_student_id) if @student_timing.present?
          @gp |= inst_student.group_classes.pluck(:id) if @student_timing.present?
        end
      end
      # @inst_stu=@inst_stu.join(",").split(",").map { |s| s.to_i }
    elsif params[:award_id].present?
      @unregistered_award = Award.find(params[:award_id])
      @instructor_student = current_admin_user.instructor_students.where(:is_deleted => false).pluck(:id)
      @instructor_student_awards_student_list = InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress LIKE (?) AND is_registered = false AND award_id = (?)", @instructor_student, 'ready_for', params[:award_id] ).pluck(:instructor_student_id)
      
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @instructor_student_awards_student_list)
      @instructor_students.each do |inst_student|
        @gp |= inst_student.group_classes.pluck(:id)
        @inst_stu << inst_student.id
      end
    end
    @stu_group_class=GroupClass.where("Id IN (?)",@gp)
    current_admin_user.group_classes.each do |group_class|
      @group_class = group_class
      generate_fee_and_attendance_months
    end
  end

  def unregistered_students
    group_class_view
    @inst=InstructorStudent.where("Id IN (?)",current_admin_user.active_student_ids).includes(:fees)
    @inst_stu =[]
    @gp=[]
    if params[:award_id].present?
      @unregistered_award = Award.find(params[:award_id])
      @instructor_student = current_admin_user.instructor_students.where(:is_deleted => false).pluck(:id)
      @instructor_student_awards_student_list = InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress LIKE (?) AND is_registered = false AND award_id = (?)", @instructor_student, 'ready_for', params[:award_id] ).pluck(:instructor_student_id)
      
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @instructor_student_awards_student_list)
      @instructor_students.each do |inst_student|
        @gp |= inst_student.group_classes.pluck(:id)
        @inst_stu << inst_student.id
      end
    end
    @stu_group_class=GroupClass.where("Id IN (?)",@gp)
    current_admin_user.group_classes.each do |group_class|
      @group_class = group_class
      generate_fee_and_attendance_months
    end
    render template: "instructor/home/unpaid_fee_student"
  end

  def sort_student
    @group_class = current_admin_user.group_classes.find(params[:id])
    @students_list = current_admin_user.group_classes.find(params[:id]).instructor_students.where(:group_id => nil)
    generate_fee_and_attendance_months
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
  end

  def generate_fee_and_attendance_months
    
    today_date = Date.today.at_beginning_of_month
    if params[:is_submit].present?
      if params[:fee_check].present?
        @fee_attendance='fee'
      elsif params[:isAttendance].present?
        @fee_attendance='attendance'
      elsif params[:latestLesson].present?
        @fee_attendance='latestLesson'
      elsif params[:isFeeAttendance].present?
        @fee_attendance='fee_attendance'
      else
        @fee_attendance='no'
      end
      @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.find_by_table_name("group_class")
      
      # highlight_ready
      if params[:highlight_ready].present?
        @highlight_ready = params[:highlight_ready]
        if params[:ready_cell_month].present?
          @ready_cell_month=params[:ready_cell_month]
        end
      else
        @highlight_ready = false
        @ready_cell_month = @add_or_more_less_months_saved_settings.ready_cell_month
      end

      # highlight_training
      if params[:highlight_training].present?
        @highlight_training = params[:highlight_training]
      else
        @highlight_training = false
        # @training_cell_month = @add_or_more_less_months_saved_settings.training_cell_month
      end
      @add_or_more_less_months_saved_settings.update_attributes(highlight_ready:@highlight_ready,ready_cell_month: @ready_cell_month, highlight_training: @highlight_training)
      
      if @fee_attendance == "attendance"
        @add_or_more_less_months_saved_settings.update(start_month_atte: '1 '.to_s + params[:start_month_atte], end_month_atte: end_month(params[:end_month_atte]),fee_attendance: @fee_attendance) if params[:start_month_atte].present? && params[:end_month_atte].present?
      elsif @fee_attendance == "latestLesson"
        @add_or_more_less_months_saved_settings.update(fee_attendance: 'latestLesson')
      elsif @fee_attendance == 'fee'
        @add_or_more_less_months_saved_settings.update(start_month: '1 '.to_s + params[:start_month], end_month: end_month(params[:end_month]),fee_attendance: 'fee') if params[:start_month].present? && params[:end_month].present?
      elsif @fee_attendance == 'fee_attendance'
        @add_or_more_less_months_saved_settings.update(start_month_view_atte: '1 '.to_s + params[:start_month_view_atte], end_month_view_atte: end_month(params[:end_month_view_atte]),fee_attendance: 'fee_attendance') if params[:start_month_view_atte].present? && params[:end_month_view_atte].present?
      else
         @add_or_more_less_months_saved_settings.update(fee_attendance: 'no')
      end
    else
      if current_admin_user.more_or_less_months.count == 0
        @start_month = Date.today.beginning_of_month
        @end_month = (Date.today + 2.month).end_of_month
        @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.create(start_month: @start_month, end_month: @end_month, start_month_atte: @start_month, end_month_atte: @end_month,start_month_view_atte: @start_month,end_month_view_atte: @end_month,table_name: "group_class", fee_attendance: 'no',highlight_ready: false,font_size: 10)
        # @fee_attendance=current_admin_user.more_or_less_months.find_by_table_name("group_class").fee_attendance
        # @ready_cell_month=@more_or_less_month.ready_cell_month
      else
        @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.find_by_table_name("group_class")
      end
      @fee_attendance=@add_or_more_less_months_saved_settings.fee_attendance
      @highlight_ready=@add_or_more_less_months_saved_settings.highlight_ready
      @ready_cell_month=@add_or_more_less_months_saved_settings.ready_cell_month
      @highlight_training= @add_or_more_less_months_saved_settings.highlight_training
    end
    # if current_admin_user.more_or_less_months.count == 0
    #   current_admin_user.more_or_less_months.create(table_name: "group_class", fee_attendance: @fee_attendance,highlight_ready: @highlight_ready,ready_cell_month: @ready_cell_month)
    # else
    #   current_admin_user.more_or_less_months.find_by_table_name("group_class").update(fee_attendance: @fee_attendance,highlight_ready: @highlight_ready,ready_cell_month: @ready_cell_month)
    # end
    # @fee_attendance=current_admin_user.more_or_less_months.find_by_table_name("group_class").fee_attendance
    # @more_or_less=current_admin_user.more_or_less_months.find_by_table_name("group_class")
   
    if @fee_attendance == "attendance" || @fee_attendance == "latestLesson" 
      # start_date = @more_or_less.start_month_atte
      # end_date = @more_or_less.end_month_atte
      @startMonth = @add_or_more_less_months_saved_settings.start_month_atte
      @endMonth = @add_or_more_less_months_saved_settings.end_month_atte
      
    elsif @fee_attendance == "fee"
      @startMonth = @add_or_more_less_months_saved_settings.start_month
      @endMonth = @add_or_more_less_months_saved_settings.end_month
    elsif @fee_attendance == "fee_attendance"
      @startMonth = @add_or_more_less_months_saved_settings.start_month_view_atte
      @endMonth = @add_or_more_less_months_saved_settings.end_month_view_atte
    else
      @startMonth = (Date.today - 1.months)
      @endMonth = Date.today
    end
    displayDays = [@group_class.day]
    @endMonth = Date.today if @fee_attendance == "latestLesson" || @endMonth.nil?
    @startMonth = (Date.today - 1.month) if @startMonth.nil?
    @result = (@startMonth..@endMonth).to_a.select {|k| displayDays.include?(k.wday)} if @fee_attendance != "no"
    
    if @fee_attendance == "attendance"
      @is_attendace = 'checked'
    elsif @fee_attendance == "fee"
      # if @show_amount==true
      #   @show_amout = 'checked'
      # end
      @is_fees_check = 'checked'
    elsif @fee_attendance == "latestLesson"
      @is_lesson_check = 'checked'
    elsif @fee_attendance == "fee_attendance"
      @is_view_fee_attendance = 'checked'
    end
    @is_highlight_ready = @highlight_ready ? 'checked' : 'unchecked'
    @is_highlight_training = @highlight_training ? 'checked' : 'unchecked'
    # month = @endMonth.to_date.strftime("%m").to_i
    # year = ('1-'+@endMonth).to_date.strftime("%Y").to_i
    # # endDateCnt = days_in_month(month, year)
    # endDateCnt = Time.days_in_month(month, year)
    # @start_date_att = @startMonth
    # @end_date_att = @endMonth
    # @end_date_att = @endMonth.to_date.end_of_month()
  end

  def remove_group_from_group_class
    @group = Group.find_by_id(params[:id])
    @group_class = GroupClass.find(@group.group_class_id)
    @groups = @group_class.groups
    @group.destroy
    respond_to :js
  end

  def opportunity
    @jobs = Job.where(:job_status => "Post", :class_type => '7', :instructor_id => nil)
    @new_jobs = []
    @jobs_pending  = []
    @jobs.each do |job|
      @instructor_job_application = InstructorJobApplication.find_by_job_id_and_instructor_id(job.id,current_admin_user.id)
      if !@instructor_job_application.blank?
        if @instructor_job_application.applied == true
          @jobs_pending  << job
        end
      else
        @new_jobs  << job
      end
    end
    @total_new_jobs = @new_jobs.count 
    @total_pending_jobs = @jobs_pending.count
    @new_jobs = @new_jobs.sort_by(&:"id").reverse.paginate(:page => params[:page], :per_page => 10)
    @jobs_pending = @jobs_pending.sort_by(&:"id").reverse.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def referrals 

    # Start For opportunity page ( Opprotunity tab and Pending Tab)

        @jobs = Job.where(:job_status => "Post", :class_type => '7', :instructor_id => nil)
        @new_jobs = []
        @jobs_pending  = []
        @jobs.each do |job|
          @instructor_job_application = InstructorJobApplication.find_by_job_id_and_instructor_id(job.id,current_admin_user.id)
          if !@instructor_job_application.blank?
            if @instructor_job_application.applied?
              @jobs_pending  << job
            end
          else
            @new_jobs << job
          end
        end
        @total_new_jobs = @new_jobs.count 
        @total_pending_jobs = @jobs_pending.count
        @new_jobs = @new_jobs.sort_by(&:"id").reverse.paginate(:page => params[:page], :per_page => 10)
        @jobs_pending = @jobs_pending.sort_by(&:"id").reverse.paginate(:page => params[:page], :per_page => 10)

    # End


    items = [
      "Receipt",
      "receipt"
    ]
    attended = ["attended","Attended"]
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @jobs = Job.where(:instructor_id => current_admin_user.id).where("first_attendance NOT IN (?)", attended).where("job_status IN (?)", items).order('start_date desc').paginate(:page => params[:page], :per_page => 10)
    @attended_jobs = Job.where(:first_attendance => "Attended", :instructor_id => current_admin_user.id).where("job_status IN (?)", items).order('start_date desc').paginate(:page => params[:page], :per_page => 10)
    @group_classes = current_admin_user.group_classes.order('day asc,time asc')
    respond_to do |format|
      format.js
      format.html
    end
  end

  def set_attended
    @job = Job.find(params[:id])
    @job.update_attributes(:first_attendance => "Attended")
    @reward = Reward.create(:instructor_id => current_admin_user.id, :job_id => @job.id, :points => @job.referral)
  end

  def apply_for_job
    instructor_id = current_admin_user.id
    job_id = params[:job_id]
    description = params[:description]
    @instructor_job_application = InstructorJobApplication.create(:job_id => job_id, :description => description, :instructor_id => instructor_id, :applied => true)
  end

  def register_for_test
    @award = Award.find(params[:award_id])
    @award_tests = AwardTest.where(:award_id => @award.id).order("test_date asc, test_time asc")
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student_awards = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_id => @award.id)
  end

  def unregister_for_test
    @award = params[:award_id]
    #@award_tests = AwardTest.where(:award_id => @award.id)
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student_awards = InstructorStudentAward.find_by(:instructor_student_id => @instructor_student.id,  :award_test_id => @award )
    @instructor_student_award_unregister = @instructor_student_awards.update(:award_test_id => nil, :is_registered => false)
    redirect_to instructor_instructor_student_path(@instructor_student)
  
  end

  def get_registered_for_test
    # params[:userXauth] : (WITHOUT AUTH STUDENT CAN EDIT HIS/HER PROFILE) If part for student can choose from out side and else part here says
    #                      After instructor login, on register now button click. 
    # exit
    logger.info "<---------------#{params}------------>"
    @award_test = params[:award_test_id]
    @award = params[:award_id]
    logger.info "<----#{@award}---#{@award_test}------->"
    if params[:userXauth]
      student = InstructorStudent.find_by_secret_token(params[:userXauth])
      logger.info "<--1---#{@instructor_student_award.inspect}------------------>"
      @instructor_student_award = InstructorStudentAward.where(:instructor_student_id => student.id, :award_id => @award, :award_progress => "ready_for")
      student.update_attributes(:is_registered => true)
      logger.info "<--2---#{@instructor_student_award.inspect}------------------>"
    else
      student = InstructorStudent.find(params[:inst_student_id])
      logger.info "<--3---#{student.inspect}------------------>"
      @instructor_student_award = InstructorStudentAward.where(:instructor_student_id => params[:inst_student_id], :award_id => @award)
      student.update_attributes(:is_registered => true)
      logger.info "<--4---#{student.inspect}------------------>"
    end
    @instructor_student_award.each do |p|
      if p.award_test_id.blank?
        p.update_attributes(:award_test_id => @award_test, :award_progress => 'ready_for', :is_registered => true, :status => "Pending")
      else
        p.update_attributes(:award_test_id => @award_test, :award_progress => 'ready_for', :is_registered => true, :status => "Pending")
      end
    end

    if params[:gpc]
      group_class = params[:gpc]
    else
      group_class = params[:group_class_id]
    end
    # if params[:userXauth]
    #   userXauth = params[:userXauth] # + '~' + @award + '.' + @award_test
    #   redirect_to student_public_link_path(userXauth)
    # else
    #   if params[:instructorStudent]
    #     redirect_to instructor_instructor_students_path
    #   else
    #     redirect_to instructor_group_class_view_path(group_class)
    #   end
    # end
    redirect_to award_test_payment_options_path(student.secret_token,@award_test)
  end

  def check_availablity_for_test
    logger.info"<------------#{params}----------------->"
    @total_slot=AwardTest.find(params[:id]).total_slot
    @total_student= InstructorStudentAward.where(:award_test_id => params[:id]).count
    @total_available= @total_slot - @total_student
    render :html => @total_available
  end

  def remove_fee
    logger.info"<---------------#{params}------------------>"
  end

  def edit_per_course_fee
  end

  def get_edit_fee_modal
    logger.info"<---------------#{params}------------------>"
    @student = InstructorStudent.find(params[:student])
    @group_class = GroupClass.find(params[:group_class])
    @fee = Fee.find(params[:fee])
    respond_to do |format|
      format.js
    end
  end

  def update_instructor_student_award_status
    # @instructor_student_award=InstructorStudentAward.new
    if params[:id] != ""
      if InstructorStudentAward.find_by(instructor_student_id: params[:student_id].to_i).nil?
        Award.all.each do |award|
          @instructor_student_award = award.instructor_student_awards.build(instructor_student_id: params[:student_id].to_i)
          @instructor_student_award.save
        end
      end
      @instructor_student_award=InstructorStudentAward.find_by(award_id: params[:id].to_i, instructor_student_id: params[:student_id].to_i)
      @instructor_student_award.update(award_progress: params[:status])
      if params[:status] == "ready_for"
        @instructor_student_award.update(is_registered: false)
      end
    end
    respond_to :js
  end

  def remove_training_instructor_student_award
    @instructor_student_award=InstructorStudentAward.find(params[:id].to_i)
    @instructor_student_award.update(award_progress: nil,status: nil,is_registered: false)
    respond_to :js
  end

  # def whether_information
  #   url = 'http://www.weather.gov.sg/srv/lightning/lightning_alert_ssc.html'

  #   #using mechanize
  #   # agent = Mechanize.new
  #   # agent.add_auth(url, 'sscops', 'sscops123')
  #   # doc = agent.get(url)
  #   # # web_title = agent.page.title
  #   # @content = agent.page.content
    
  #   #using nokogiri
  #   doc = Nokogiri::HTML(open(url, :http_basic_authentication => ['sscops' ,'sscops123']))
  #   rows = doc.css('tr')
  #   if rows.length > 0 
  #     location,risk,time = nil
  #     rows[3..-1].each do |row|
  #       cells = row.css('td')
  #       location,risk,time = cells[0..2].map{|c| c.text}
  #       if location.include?("Swimming Complex")
  #         @lightning_risk = LightningRisk.find_by_location(location)
  #         if !@lightning_risk.blank?
  #           @lightning_risk.update_attributes(:risk => risk , :time => time)
  #         else
  #           @lightning_risk = LightningRisk.create(:location => location, :risk => risk, :time => time)
  #         end  
  #       end  
  #     end 
  #   end      
  #   @lightning_risks = LightningRisk.all
  #   # doc.css("table:first-child").each do |item|
  #   #   item.css("tr").each do |tr|
  #   #     tr.css("td").each do |td|
  #   #       puts td.content
  #   #     end
  #   #   end
  #   # end
  # end

  def mark_present
    if @attendance.blank?
      @attendance = StudentAttendance.create(group_class_id: @group_class, instructor_student_id: @student,
                                             attendance_date: @attendance_date, attendance_status: "present",attendance: params[:date])
    else
      @attendance = @attendance.first
      @attendance.update_attributes(attendance_status: "present")
    end
  end

  def mark_absent
    if @attendance.blank?
      @attendance = StudentAttendance.create(group_class_id: @group_class, instructor_student_id: @student,
                                             attendance_date: @attendance_date, attendance_status: nil,attendance: params[:date])
    else
      @attendance = @attendance.first
      @attendance.update(attendance_status: nil)
    end
  end

  def remove_attendance
    @attendance = @attendance.first.destroy
  end

  def mark_attendance
    @attendance_date  = params[:attendance_date]
    @group_class = params[:group_class]
    @student = params[:student]
    @attendance = StudentAttendance.where(group_class_id: @group_class, instructor_student_id: @student, attendance_date: @attendance_date)
  end

  def save_font_size
    if current_admin_user.more_or_less_months.count == 0
      @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.create(table_name: "group_class", font_size: params[:size])
    else
      @add_or_more_less_months_saved_settings = current_admin_user.more_or_less_months.find_by_table_name("group_class")
      @add_or_more_less_months_saved_settings.update(font_size: params[:size])
    end
    render json: @add_or_more_less_months_saved_settings.font_size
  end

  def transfer_modal
    @transfer = Transfer.find(params[:transfer])
    @day_list = current_admin_user.group_classes.pluck(:day).uniq
    @group_classes = current_admin_user.group_classes.where(is_deleted: false)
  end

  def transfer_student_in
    transfer = Transfer.find(params[:transfer])
    if transfer && transfer.transfer_status == "Transferring" 
      # studentId = transfer.instructor_student_id
      group_classes = params[:group_class_ids]
      # instructorStudent = InstructorStudent.find(studentId)
      instructorStudent = transfer.instructor_student
      # InstructorStudentGroupClass.where(instructor_student_id: instructorStudent.id).delete_all
      #---------------------make previous group class entry in history table---------------------
      @previous_class_ids = instructorStudent.group_class_ids
      if @previous_class_ids.present?
        instructorStudent.student_group_class_histories.create(:group_class_id=>@previous_class_ids.join(" ").to_i)
      end
      # student = instructorStudent.clone

      # newStudent = student.dup
      # newStudent.save
      # newStudent.update(admin_user_id: transfer.transfer_to, group_id: nil)

      # ............... START COPY STUDENT CONTACT DETAIL .................
        # instructorStudent.student_contacts.each do |contact|
        #   StudentContact.create instructor_student_id: newStudent.id, relationship: contact.relationship, name: contact.name, contact: contact.contact,
        #                         primary_contact: contact.primary_contact, email: contact.email 
        # end
      # ............... END COPY STUDENT CONTACT DETAIL .................

      # ==================================================================================================================================================================

      # ............... START COPY STUDENT AWARD DETAIL .................
        # student.instructor_student_awards.each do |award|
        #   InstructorStudentAward.create instructor_student_id: newStudent.id, award_id: award.award_id, achieved_date: award.achieved_date,
        #                                 award_progress: award.award_progress, award_test_id: award.award_test_id, status: award.status, is_registered: award.is_registered
        # end
      # ............... END COPY STUDENT AWARD DETAIL .................
      instructorStudent.update(admin_user_id: transfer.transfer_to, group_id: nil)
      if group_classes.present?
        instructorStudent.group_class_ids = group_classes
      end
      # group_classes.each do |p|
      #   if !p.empty?
      #     InstructorStudentGroupClass.create(instructor_student_id: newStudent.id, group_class_id: p)
      #   end
      # end
      transfer.update(transfer_status: "Transferred")#, new_student_id: newStudent.id)
      redirect_to instructor_dashboard_path, notice: "Transfer student is done."
    else
      redirect_to instructor_dashboard_path, alert: "Transfer was already cancelled."
    end
  end

  def reject_transfer_student
    transfer = Transfer.find(params[:transfer])
    if transfer.transfer_status != "Transferred"
      if transfer
        transfer.update transfer_status: "Rejected"
      end
    end
    if params[:controller] == "instructor/home" && params[:action] == "dashboard"
      redirect_to instructor_dashboard_path, alert: "Transfer student is rejected or cancelled."
    else
      if params[:gp]
        redirect_to instructor_instructor_student_path(transfer.instructor_student_id, :gp => params[:gp]), alert: "Transfer student is rejected or cancelled."
      else
        redirect_to instructor_dashboard_path, alert: "Transfer student is rejected or cancelled."
      end
    end
  end

  def get_fee_data
    @group_class = GroupClass.find(params[:group_class_id])
    @student = InstructorStudent.find(params[:student_id])
    @month = params[:month]
    if params[:fee]
      @fee = Fee.find(params[:fee])
    else
      @fee = Fee.new()
    end
  end
  def group_classes_deatil_print
    @group_classes = GroupClass.where(id: params[:group_class_ids].split(','))
    @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name("group_class")
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @group_class = GroupClass.first
    logger.info"<======#{@group_classes.inspect}=========>"
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    generate_fee_and_attendance_months
    # instructor_group_classes_deatil_print_path
  end

  private
  def group_class_params
    params.require(:group_class).permit(:slot_maximum, :day, :time, :fee_type_id, :duration, :level_id, :instructor_id, :venue_id, :age_group_id, :class_type_id, :lesson_count, :remarks, :fee, :admin_user_id) rescue {}
  end

  def check_hide_show_columns
    @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name("group_class")
    if @hide_show_columns.blank?
      @hide_show_columns = current_admin_user.hide_show_columns.create(table_name: "group_class", name: "true", contact: "true",
                                ic_number: "true", date_of_birth: "true", join_date: "true",
                                description: "true", ready_for: "true", training_for: "true",
                                registered_for: "true", achieved: "true", profile_pic: "true")
    end
  end

  def check_hide_show_columns_grp_cls_index
    @hide_show_columns_grp_cls_index = current_admin_user.hide_show_columns.find_by_table_name("group_class_list")
    if @hide_show_columns_grp_cls_index.blank?
      @hide_show_columns_grp_cls_index = current_admin_user.hide_show_columns.create(table_name: "group_class_list", venue: "true", age_group: "true", level: "true",
                                fee: "true", fee_type: "true", students: "true", max_slot: "true",
                                vacancy: "true")
    end
  end

  def generate_month_according_current_month
    leftSideMonths = 1..6
    rightSideMonths = -6..0 

    @previousMonths = []
    leftSideMonths.each do |n|
      @previousMonths << n.months.ago.to_date.strftime("%b-%y")
    end

    @nextMonths = []
    rightSideMonths.each do |n|
      @nextMonths << n.months.ago.to_date.strftime("%b-%y")
    end
  end

  def days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end

  def end_month(month)
    return month.to_date.end_of_month
  end

  # def check_user_log_in
  #   if !admin_user_signed_in?
  #     redirect_to manage_root_path
  #   elsif current_admin_user.accountant?
  #     redirect_to accountant_root_path
  #   end
  # end
end