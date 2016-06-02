class InstructorJobApplicationDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def v
    @view
  end  
 
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: InstructorJobApplication.count,
    iTotalDisplayRecords: instructor_job_applications.total_entries,
    aaData: data
   }
  end



private
  def data
    @instructor_job_applications = instructor_job_applications
    @instructor_job_applications.to_a.map do |ins_job|
      @job = Job.find_by_id(ins_job.job_id)
      if !ins_job.instructor_id.blank?
        @instructor = Instructor.find_by_id(ins_job.instructor_id)
        if !@instructor.blank?
          @instructor_name = @instructor.name
        else
          @instructor_name = "" 
        end
      end
      puts "<----------#{ins_job.inspect}----------------->"
      #@actions = '<a class="btn default btn-xs href="'+@view.edit_manage_instructor_path(instructor)+'"><i class="fa fa-edit"></i>Edit</a>'
      [
        ins_job.updated_at.strftime("%d-%b %l:%M %P"),
        link_to(ins_job.job_id,[:manage ,@job]),
        @instructor_name,
        ins_job.ionic_request,
        ins_job.description ? (ins_job.description).html_safe : '' ,
        link_to('Delete',[:manage , ins_job], method: :delete, :'data-confirm' => "Are you sure?")
      ]
    end
  end
  def fetch_instructor_job_applications
    instructor_job_applications = InstructorJobApplication.where(:applied => true).order("#{sort_column} #{sort_direction}")
    instructor_job_applications = instructor_job_applications.page(page).per_page(per_page)
    instructor = Instructor.where("LOWER(name) like ?", "%#{params[:sSearch].downcase}%")
    if !instructor.blank?
      instructor = instructor.first.id.to_s
    end 
    if params[:sSearch].present?
      if instructor.present?
        instructor_job_applications = instructor_job_applications.where("instructor_id = :instructor
                      or '%'||updated_at||'%' LIKE :search 
                      or job_id::text LIKE ('%'::text || :search)
                      or LOWER(description) LIKE :search 
                      ",instructor: instructor ,search: "%#{params[:sSearch].downcase}%")
      else  
        instructor_job_applications = instructor_job_applications.where("'%'||updated_at||'%' LIKE :search 
                      or job_id::text LIKE ('%'::text || :search)
                      or LOWER(description) LIKE :search
                      ",search: "%#{params[:sSearch].downcase}%")
      end  
    end
   
    instructor_job_applications
  end

  def instructor_job_applications
    @instructor_job_applications ||= fetch_instructor_job_applications
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[updated_at job_id instructor_id description]
    puts "----#{params[:iSortCol_0].to_i}"
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
