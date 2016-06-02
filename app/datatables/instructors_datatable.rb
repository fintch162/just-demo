class InstructorsDatatable
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
    iTotalRecords: Instructor.count,
    iTotalDisplayRecords: instructors.total_entries,
    aaData: data
   }
  end

private
  def data
    @cnt = params[:iDisplayStart].to_i
    @instructors = instructors
    @instructors.to_a.map do |instructor|
      #@actions = '<a class="btn default btn-xs href="'+@view.edit_manage_instructor_path(instructor)+'"><i class="fa fa-edit"></i>Edit</a>'
      [
        link_to(@cnt+=1,[:manage , instructor]),
        instructor.status,
        link_to(instructor.name, [:manage, instructor]),
        instructor.mobile,
        instructor.note,
        instructor.email,
        instructor.last_activity ? instructor.last_activity.strftime('%I:%M%P %e %b,%Y') : ''
        #,
        # @actions
        #link_to('<i class="fa fa-edit"></i>Edit'.html_safe,@view.edit_manage_instructor_path(instructor), :class => 'btn default btn-xs')
      ]
    end
  end
  def fetch_instructors
    instructors = Instructor.order("#{sort_column} #{sort_direction}")
    instructors = instructors.page(page).per_page(per_page)
  
    if params[:sSearch].present?
        instructors = instructors.where("LOWER(name) LIKE :search 
                      or id::text LIKE ('%'::text || :search)
                      or LOWER(email) LIKE  :search
                      or LOWER(note) LIKE :search
                      or LOWER(mobile) LIKE :search
                      ",search: "%#{params[:sSearch].downcase}%")
    end
   
    instructors
  end

  def instructors
    @instructors ||= fetch_instructors
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id name mobile email]
    puts "----#{params[:iSortCol_0].to_i}"
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
