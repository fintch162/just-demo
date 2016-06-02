class EmbedRegistrationFormsController < ApplicationController
  # respond_to :js , only: [:create]
  def new

    @job = Job.new
    @job.students.build
    5.times { @job.preferred_days.build}
    @venues = Venue.where(['name not in (?)', ["Buona Vista Swimming Complex","Bukit Timah Swimming Complex","Kallang Basin Swimming Complex", "Condo"]])
    render :layout => "embed_registration_form"
  end
  
  def create
    logger.info("<.........#{params}.....................>")

    params[:job][:students_attributes].each do |s|
      if !s[1]['name'].present?
        s[1]['_destroy'] = true
      end
    end
    if params[:job][:registration_package_id].present?
      a = params[:job][:registration_package_id]
      b = a.split(",")[1]
      params[:job][:registration_package_id] = b.to_i
      @job = Job.new(job_params)
      if @job.save
        @job.update(class_type: job_params[:lead_class_type])
        EmbedRegistration.registration_info(@job).deliver
        # format.html { redirect_to embed_registration_detail_path(@job)}
        redirect_to "http://www.singaporeswimming.com/submission-successful/"
      else
        render json: {}, status:  422
      end
    else
      @job = Job.new(job_params)
      if @job.save
        if job_params[:lead_class_type].present?
          @job.update(class_type: job_params[:lead_class_type])
          EmbedRegistration.registration_info(@job).deliver
        end
        # format.html { redirect_to embed_registration_detail_path(@job)}
        if params[:booking_schedule].present?
          redirect_to booking_schedule_path
        else
          redirect_to "http://www.singaporeswimming.com/submission-successful/"
        end
      else
        render json: {}, status:  422
      end
    end
  end

  def generator
    @job = Job.new
    @job.students.build
    5.times { @job.preferred_days.build}
    @venues = Venue.where(['name not in (?)', ["Buona Vista Swimming Complex","Bukit Timah Swimming Complex","Kallang Basin Swimming Complex", "Condo"]])
    render :layout => "embed_registration_form"  
  end
  
  def show
    @job = Job.find(params[:id])
    render :layout => "embed_registration_form"
  end
  private
    def job_params
      params.require(:job).permit(:referred,:duration,:group_class_id,:is_insurance,:private_lesson_venue_id, :lead_lady_instructor_only, :lead_affiliate,:lead_class_type,:other_venue ,:private_lesson, :lead_condo_name, :lead_day_time, :lead_starting_on ,:post_date ,:instructor_id, :venue_id ,:preferred_time ,:referral ,:par_pax ,:fee_total ,:age_group ,:class_level ,:start_date ,:class_type ,:venue ,:lead_email ,:lead_contact ,:lead_name ,:day_of_week ,:customer_contact ,:customer_name ,:first_attendance ,:goggles_status ,:lock_date ,:message_to_instructor ,:job_status ,:message_to_customer ,:coordinator_notes ,:lead_info ,:lead_address ,:lesson_count ,:fee_type_id ,:class_time ,:completed_by ,:show_names ,:free_goggles ,:lady_instructor,:registration_package_id, venue_ids: [], :preferred_days_attributes => [:id, :job_id, :day,:preferred_time],:students_attributes => [ :id, :job_id, :name, :age, :age_month, :sex, :_destroy]) rescue {}
    end
end