class Instructor::InstructorProfileController < Instructor::BaseController
  # before_action :check_telerivet_settings, :only => [:update]
  before_action :check_user_permission
   def edit
    @instructor = current_admin_user
    respond_to do |format|
      format.html 
    end
  end

  def update
    if params[:instructor][:profile_picture].present?
      update_instructor
    end
    if params[:cmpSetting].present?
      if params[:instructor][:company_logo] == ""
        update_instructor
        @instructor = current_admin_user
        @instructor.company_logo = nil
        @instructor.save
      else
        update_instructor
      end
    else
      if params[:smsSetting].present? || params[:pwdSetting].present?
        update_instructor
      end
      if params[:instructor][:telerivet_api_key]
        generate_telerivet_api
        update_instructor
      end
      update_instructor
    end
    respond_to do |format|
      format.html do
        if @instructor.valid?
          redirect_to "/instructor/profile", :notice => "<strong>Done! </strong>Your data has been saved."
        else
          render "edit"
        end
      end
    end  
  end

  def disconnect_telerivet_account
    @instructor = current_admin_user
    @instructor.update(telerivet_api_key: "", instructor_telerivet_project_id: "", instructor_telerivet_phone_id: "", instructor_webhook_api_secret: "")
    @instructor.update(is_account_activated: false)
    redirect_to instructor_profile_path+"#sms_setting", :notice => "Account has been disconnected."
  end

  def instructor_features
    ids =[]
    if params[:instructor_features]
      params[:instructor_features].each do |inst_feature|
        ids << inst_feature[0]
        InstructorFeature.find(inst_feature[0]).update(is_enabled: true)
      end
    else
      current_admin_user.instructor_features.update_all(is_enabled: false)
    end
    current_admin_user.instructor_features.where('id NOT IN (?)',ids).update_all(is_enabled: false)
    flash[:notice] = 'Features updated successfully.'
    redirect_to :back
  end
  def export # Not used anywhere
    @instructor = current_admin_user
    @fee_type = FeeType.find_by(name: 'per month')
    @group_classes = @instructor.group_classes.where(fee_type_id: @fee_type.id).order('day asc,time asc').where(is_deleted: false)
    days_arry = []
    all_days_arr = []
    @group_classes.each do |group_class|
      if group_class.day.to_i == 0
        days_arry << group_class
      else
         all_days_arr << group_class
      end
    end
    @group_classes = all_days_arr + days_arry
    @day = Job::DAY_NAMES
    @m = 11
    current_year_start_date = Date.today.beginning_of_year
    @month_array = []
    (0..@m).each do |m|
      @month_array << (current_year_start_date + m.month)
    end

    respond_to do |format|
      format.html
    end
    # render xlsx: 'export'
  end

  def update_daily_backup_email_setting
    @instructor = current_admin_user
    if @instructor.update_attributes(daily_backup_on: params[:backup])
      render json: { backup: @instructor.daily_backup_on, success: true }
    else
      render json: { success: false, error: true }
    end
  end
  private
    def generate_telerivet_api
      api_key = params[:instructor][:telerivet_api_key]
      project_id = params[:instructor][:instructor_telerivet_project_id]
      phone_id = params[:instructor][:instructor_telerivet_phone_id]

      tr = Telerivet::API.new(api_key)
      project = tr.init_project_by_id(project_id)
      phone = project.get_phone_by_id(phone_id)

      telerivet_phone_number = phone.phone_number
      current_admin_user.update_attributes(:is_account_activated => true, :telerivet_phone_number => telerivet_phone_number)
    end
    def check_telerivet_settings
      begin
        generate_telerivet_api
        redirect_to instructor_profile_path+"#sms_setting", :notice => "Your account has been activated."
      rescue Exception => e
        redirect_to instructor_profile_path+"#sms_setting", :notice => "#{e}"
      end
    end

    def update_instructor
      @instructor = current_admin_user
      if instructor_params[:password].blank?
        instructor_params.delete("password")
        instructor_params.delete("password_confirmation")
      end
      @instructor.update(instructor_params)
    end
    def instructor_params
      params.require(:instructor).permit!
    end
end