class Manage::RegistrationController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  skip_before_filter :authenticate_admin_user!
  before_action :check_user_permission, only: [ :new, :create, :edit, :embed_registration_form ]

  def new
    @job = Job.new
    @job.students.build
    5.times { @job.preferred_days.build}
    if !admin_user_signed_in?
      render :layout => "swimming_lession_outside"
    end
  end

  def create
  end

  def edit
    @job = Job.find(params[:id])
    if @job.preferred_days.count == 0
      5.times { @job.preferred_days.build}
    end
  end

  def embed_registration_form
    @job = Job.new
    @job.students.build
    if !admin_user_signed_in?
      render :layout => "swimming_lession_outside"
    end
  end
  private
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
