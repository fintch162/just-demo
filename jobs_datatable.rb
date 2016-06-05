class JobsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: Job.count,
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
      # elsif !job.private_lesson_venue_id.blank?
      #   @venue = Venue.find(job.private_lesson_venue_id).name if !job.private_lesson_venue_id.blank?
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
      # @job_freshbook_invoices = []
      # freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      # @freshbook_invoices = freshbookconnection.invoice.list.to_json
      

      # @freshbook_invoices =JSON.parse(@freshbook_invoices)["invoices"]
      # @total = @freshbook_invoices["total"].to_i
      # if !@total.blank?
      #   if @total == 1
      #     if @freshbook_invoices["invoice"]["po_number"].to_i == job.id.to_i 
      #       @job_freshbook_invoices << @freshbook_invoices["invoice"]
      #     end
      #   elsif @total > 1
      #     @freshbook_invoices["invoice"].each do |p| 
      #       if p["po_number"].to_i == job.id.to_i
      #         @job_freshbook_invoices << p
      #       end
      #     end  
      #   end
      # end
      # if !@job_freshbook_invoices.blank?
      #   @latest_invoice = @job_freshbook_invoices.first["number"]
      # else
      #   @latest_invoice = ""
      # end



                                                # Commented Code To Hide Invoice Column ( When on index page you want to show Invoice Coulumn comment out this code)
                                                      # @invoices = job.invoices.last
                                                      # if !@invoices.blank?
                                                      #   @latest_invoice = @invoices.invoice_number
                                                      # else
                                                      #   @latest_invoice = ""  
                                                      # end




      # if !@job_freshbook_invoices.blank?
      
      #       @actions = '<div class="btn-group">' +
      #                   '<button class="btn blue dropdown-toggle" type="button" data-toggle="dropdown">
      #                     Invoices <i class="fa fa-angle-down"></i>
      #                   </button>' + 
      #                   '<ul class="dropdown-menu" role="menu">'  
      #                     @job_freshbook_invoices.each do |job_freshbook_invoice|
      #                       @actions +=  '<li class="dropdown-submenu">
      #                         <a href="javascript:;"> '+job_freshbook_invoice["number"]+'</a>
      #                         <ul class="dropdown-menu" style="left: -100% !important;">
      #                           <li>  
      #                             <a href="'+job_freshbook_invoice["links"]["view"]+'" target="_blank">View Invoice</a>
      #                           </li> 
      #                           <li>
      #                             <a data-toggle="modal" id="responsiveModalOpen" data-invoice_number="'+job_freshbook_invoice["number"].to_s+'" data-invoice_id="'+job_freshbook_invoice["invoice_id"].to_s+'"  href="#responsive" class="add_payment" >Add Payment </a>
      #                           </li> '
      #                           @freshbook_payments = freshbookconnection.payment.list(:invoice_id => job_freshbook_invoice["invoice_id"])
      #                           @freshbook_payments = @freshbook_payments["payments"]
      #                           @total = @freshbook_payments["total"].to_i
      #                           if @total < 1
      #                            @actions +=  '<li>
      #                               <a data-toggle="modal" id="basicModalOpen" href="#basic" data-invoice_id="'+job_freshbook_invoice["invoice_id"].to_s+'" data-invoice_number="'+job_freshbook_invoice["number"].to_s+'" class="delete_invoice">Delete Invoice</a>
      #                             </li>'
      #                           end  
      #                         @actions += '</ul>

      #                       </li>'
      #                     end                  

      #                       @actions += '</ul>
      #                       </div>'
      # else
      #   @actions = ""                  
      # end
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
        @job_lead_contact
        #,# @latest_invoice
      ]
    end
  end
  def fetch_jobs
    jobs = Job.order("#{sort_column} #{sort_direction}")
    if params[:iDisplayLength] == "-1"
      jobs = jobs.page(1).per_page(jobs.count)
    else
      jobs = jobs.page(page).per_page(per_page)
    end
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

    if params[:sSearch].present? && params[:sSearch] != "undefined"
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
        if params[:sSearch].downcase == "attended"
          jobs = jobs.where(:job_status => "Receipt").where(:first_attendance => "Attended")
        elsif params[:sSearch].downcase == "receipt"
          attended = ["Attended"]
          jobs = jobs.where(:job_status => "Receipt").where("first_attendance NOT IN (?)", attended)
        else
          jobs = jobs.where("'%'||created_at||'%' LIKE :search or LOWER(job_status) LIKE :search 
                        or id::text LIKE ('%'::text || :search)
                        or LOWER(lead_name) LIKE  :search
                        or lead_contact LIKE :search
                        ",search: "%#{params[:sSearch].downcase}%")
        end
      end
    end
    
    if params[:sSearch].present? && params[:status].present? && params[:sSearch] != "undefined"
      jobs = jobs.where("LOWER(job_status) LIKE ?", params[:status].downcase)
    end

    if params[:sSearch] == "undefined"
      field_list = ['LOWER(job_status)', 'class_type', 'age_group', 'venue_id', 'created_at', 'start_date']
      value_from_params = []
      str = ""

      cnt = 0
      if params[:astatus].present? && params[:astatus] != ""
        puts "<-----#{params[:astatus]}---------->"
        str += field_list[0] + " = " + "'"+params[:astatus].downcase+"'"
        cnt = 1
      end
      if params[:aclass_type].present? && params[:aclass_type] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[1] + " = " + "'"+params[:aclass_type].to_s.downcase+"'"
        # value_from_params << params[:aclass_type].to_s
      end

      if params[:aage_group].present? && params[:aage_group] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[2] + " = " + "'"+params[:aage_group].to_s.downcase+"'"
        # value_from_params << params[:aage_group]
      end

      if params[:alocation].present? && params[:alocation] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[3] + " = " + "'"+params[:alocation]+"'"
        # value_from_params << params[:alocation]
      end

      if params[:astart_date].present? || params[:aend_date].present?
        if params[:aend_date].present?

          jobs = jobs.where(created_at:   params[:astart_date].to_date.beginning_of_day..params[:aend_date].to_date.end_of_day)
          # s_date = params[:astart_date].to_date.beginning_of_day..params[:aend_date].to_date.end_of_day
          # str += field_list[4] + " BETWEEN (?)  " + params[:astart_date].to_date.beginning_of_day..params[:aend_date].to_date.end_of_day  
        else
          jobs = jobs.where(created_at:   params[:astart_date].to_date.beginning_of_day..Date.today.end_of_day)
          # s_date = params[:astart_date].to_date.beginning_of_day..Date.today.end_of_day
          # str += field_list[4] + " BETWEEN (?)  " + params[:astart_date].to_date.beginning_of_day..Date.today.end_of_day
        end
        # value_from_params << s_date
      end

      if params[:as_start_date].present? || params[:as_end_date].present?
        
        if params[:as_end_date].present?
          # s_date = params[:as_start_date].to_date.beginning_of_day..params[:as_end_date].to_date.end_of_day
          # str += field_list[5] + " BETWEEN (?)  " +  params[:as_start_date].to_date.beginning_of_day..params[:as_end_date].to_date.end_of_day
          jobs = jobs.where(start_date: params[:as_start_date].to_date..params[:as_end_date].to_date)
        else
          # s_date = params[:as_start_date].to_date.beginning_of_day..Date.today.end_of_day
          # str += field_list[5] + " BETWEEN (?)  " +  params[:as_start_date].to_date.beginning_of_day..Date.today.end_of_day
          jobs = jobs.where(start_date: params[:as_start_date].to_date..Date.today)
        end
        # value_from_params << s_date
      end
      if !str.empty?
        jobs = jobs.where(str)
      end
      if params[:is_insurance] != "false"
        jobs = jobs.where(:is_insurance => true)
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
