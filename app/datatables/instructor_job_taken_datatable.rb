class InstructorJobTakenDatatable
  delegate :params, :h, :link_to, to: :@view
  def initialize(view)
    @view = view
    job_status = ["Invoice", "Receipt"]
    @instructor_id = params[:id]
    @job_taken = Job.where("instructor_id = ? AND job_status IN (?)", @instructor_id ,job_status).order('id desc').limit(10)
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: @job_taken.count,
    iTotalDisplayRecords: jobs.total_entries,
    aaData: data
   }
  end

private
  def data
    @jobs = jobs
    @api_setting = ApiSetting.first
    @jobs.to_a.map do |job|

      if !job.age_group.blank?
        @age_group = AgeGroup.find(job.age_group).title
      else
        @age_group = ""
      end
      if !job.venue_id.blank?
        @venue = Venue.find(job.venue_id).name.to_s.sub("Swimming Complex", 'SC')
      elsif !job.private_lesson_venue_id.blank?
        @venue = Venue.find(job.private_lesson_venue_id).name if !job.private_lesson_venue_id.blank?
      else
        @venue = ""
      end
      if !job.class_type.blank?
        @class_type = ClassType.find(job.class_type).title
      else
        @class_type = ""
      end
      if job.start_date.nil?
        @job_start_date = job.start_date
      else
        @job_start_date = job.start_date.strftime("%d %b %Y")
      end
      @job_lead_contact = job.lead_contact

      @invoices = job.invoices.last
      if !@invoices.blank?
        @latest_invoice = @invoices.invoice_number
      else
        @latest_invoice = ""  
      end     
      job_status = job.job_status
      if job.job_status == "Receipt" && job.first_attendance == "Attended"
        job_status = "Attended"
      end               
      [
        job.created_at.strftime("%d-%b"),
        link_to(job.id,[:manage , job]),
        job_status,
        @class_type,
        @age_group,
        @job_start_date,
        @venue,
        job.lead_name,
        @job_lead_contact,
        @latest_invoice
      ]
    end
  end
  def fetch_jobs
    job_status = ["Invoice", "Receipt","invoice","receipt"]
    jobs = Job.where("instructor_id = ? AND job_status IN (?)", @instructor_id ,job_status).order("#{sort_column} #{sort_direction}")
    jobs = jobs.page(page).per_page(per_page)
    class_type = ClassType.where("LOWER(title) like ?", "%#{params[:sSearch].downcase}%")
    if !class_type.blank?
      class_type = class_type.first.id.to_s
    end  
    age_group = AgeGroup.where("LOWER(title) like ?", "%#{params[:sSearch].downcase}%")
    if !age_group.blank?
      age_group = age_group.first.id.to_s
    end  
    venue = Venue.where("LOWER(name) like ?", "%#{params[:sSearch].downcase}%")
    if !venue.blank?
      venue = venue.first.id
    end

    if params[:sSearch].present?
      if class_type.present?
        jobs = jobs.where("class_type = :class_type or '%'||created_at||'%' LIKE :search
                      or id::text LIKE ('%'::text || :search) 
                      or LOWER(job_status) LIKE :search
                      or LOWER(lead_name) LIKE  :search
                      or lead_contact LIKE :search
                      ",class_type: class_type ,search: "%#{params[:sSearch].downcase}%")
      elsif age_group.present?
        jobs = jobs.where("age_group = :age_group or '%'||created_at||'%' LIKE :search
                      or id::text LIKE ('%'::text || :search) 
                      or LOWER(job_status) LIKE :search
                      or LOWER(lead_name) LIKE  :search
                      or lead_contact LIKE :search
                      ",age_group: age_group ,search: "%#{params[:sSearch].downcase}%") 
      elsif venue.present?
        jobs = jobs.where("venue_id = :venue or '%'||created_at||'%' LIKE :search
                      or id::text LIKE ('%'::text || :search) 
                      or LOWER(job_status) LIKE :search
                      or LOWER(lead_name) LIKE  :search
                      or lead_contact LIKE :search
                      ",venue: venue ,search: "%#{params[:sSearch].downcase}%")   
      else
        jobs = jobs.where("'%'||created_at||'%' LIKE :search or LOWER(job_status) LIKE :search 
                      or id::text LIKE ('%'::text || :search)
                      or LOWER(lead_name) LIKE  :search
                      or lead_contact LIKE :search
                      ",search: "%#{params[:sSearch].downcase}%")
      end
    end
   
    jobs
  end

  def jobs
    @jobs ||= fetch_jobs
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[created_at id job_status class_type age_group start_date venue_id lead_name lead_contact invoice]
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
