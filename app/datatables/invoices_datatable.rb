class InvoicesDatatable
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
    iTotalRecords: Invoice.count,
    iTotalDisplayRecords: invoices.total_entries,
    aaData: data
   }
  end



private
  def data
    @api_setting = ApiSetting.first
    @invoices = invoices
    @invoices.to_a.map do |invoice|
      if !invoice.job_id.blank?
        @job_id =   invoice.job_id
        job = Job.find_by_id(@job_id)
        @job = link_to(@job_id,[:manage,job])
      else
        @job = ""
      end
      if !invoice.job_id.blank?
        @job_status = Job.find(invoice.job_id).job_status
      else
        @job_status = ""
      end
      if !invoice.blank?
        @invoice_time = invoice.invoice_time ? invoice.invoice_time - Time.zone.now : 'No Timer Set'
      end
      if !invoice.job_id.blank?
        job = Job.find(invoice.job_id)
        if !job.start_date.blank?
          @job_start_date = job.start_date.strftime("%d-%b %Y")
        else
          @job_start_date
        end
        if !job.class_type.blank?
          @job_group_type = ClassType.find(job.class_type).title
        else
        @job_group_type = ""
        end
        if !job.age_group.blank?
          @job_age_group = AgeGroup.find(job.age_group).title
        else
          @job_age_group = ""
        end
      else
        @job_start_date = ""
        @job_group_type = ""
        @job_age_group = ""
      end
      if !invoice.job_id.blank?
        @fee_total = Job.find(invoice.job_id).fee_total
      else
        @fee_total = ""
      end
      if !invoice.job_id.blank?
        @referral = Job.find(invoice.job_id).referral
      else
        @referral = ""
      end

      # @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      # @freshbook_invoice = @freshbookconnection.invoice.get(:invoice_id => invoice.freshbooks_invoice_id)
      # puts ">>>>>>>#{@freshbook_invoice}"
      # if !@freshbook_invoice.blank?
      #   @actions = link_to(invoice.invoice_number, @freshbook_invoice["invoice"]["links"]["view"], :target => "_blank")
      # else
      #   @actions = ""
      # end
      # @actions = link_to(invoice.invoice_number, "https://tps-receivables.freshbooks.com/invoices/#{invoice.freshbooks_invoice_id}", :target => "_blank")
      @actions = link_to(invoice.invoice_number,  @view.manage_freshbook_invoice_path(:invoice_id => invoice.freshbooks_invoice_id) , :target => "_blank")

      [
        invoice.created_at.strftime("%d-%h-%y"),
        @actions,
        @job,
        @job_status,
        @invoice_time,
        @job_start_date,
        @job_group_type,
        @job_age_group,
        @fee_total,
        @referral
        # @actions
      ]
    end
  end
  def fetch_invoices
    invoices = Invoice.joins(:job).order("#{sort_column} #{sort_direction}")
    if params[:iDisplayLength].to_i > 0 
      invoices = invoices.page(page).per_page(per_page)
    else
      invoices = invoices.page(1).per_page(invoices.count)
    end
    if params[:sSearch].present? && params[:sSearch] != "undefined"
        invoices = invoices.joins(:job).where("'%'||invoices.created_at||'%' LIKE :search 
                      or invoice_number::text LIKE ('%'::text || :search)
                      or job_id::text LIKE ('%'::text || :search)
                      or LOWER(job_status) LIKE :search
                      or fee_total::text LIKE ('%'::text || :search)
                      or referral::text LIKE ('%'::text || :search)
                      ",search: "%#{params[:sSearch].downcase}%")
    elsif params[:sSearch] == "undefined"
      field_list = ['LOWER(job_status)', 'age_group', 'start_date']
      str = ""
      @jobs = Job.all
      puts "<-----#{@jobs.class}----->"
      cnt = 0
      if params[:as_start_date].present? || params[:as_end_date].present?
        puts "<-------#{params[:as_start_date]}------------>"
        end_date = params[:as_end_date].present? ? params[:as_end_date].to_date : Date.today

        # if params[:as_end_date].present?
          @jobs = @jobs.where(start_date: params[:as_start_date].to_date..end_date)
        # else
          # @jobs = @jobs.where(start_date: params[:as_start_date].to_date..Date.today)
        # end
      end
      if params[:astatus].present? && params[:astatus] != ""
        puts "<-----#{params[:astatus]}---------->"
        str += field_list[0] + " = " + "'"+params[:astatus].downcase+"'"
        cnt = 1
      end
      if params[:aage_group].present? && params[:aage_group] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[1] + " = " + "'"+params[:aage_group].to_s.downcase+"'"
      end
      # if !str.empty?
        @jobs = !str.empty? ? @jobs.where(str).pluck("id") : @jobs.pluck("id")
      # else
        # @jobs = @jobs.pluck("id")
      # end
      if (params[:astart_date].present? && params[:astart_date] != "") || (params[:aend_date].present? && params[:aend_date] != "")
        aend_date = params[:aend_date].present? ? params[:aend_date].to_date.end_of_day : Date.today.end_of_day
        # if params[:aend_date].present?
        #   invoices = invoices.where(created_at:   params[:astart_date].to_date.beginning_of_day..params[:aend_date].to_date.end_of_day)
        # else
          invoices = invoices.where(created_at:   params[:astart_date].to_date.beginning_of_day..aend_date)
        # end
      end
      puts "-----#{@jobs.class}-------"
      if @jobs.class.to_s == "Array"
        invoices = invoices.where("job_id IN (?)", @jobs)
      end
    end
    invoices
  end

  def invoices
    @invoices ||= fetch_invoices
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[invoices.created_at invoice_number job_id job_status invoice_time start_date class_type age_group fee_total referral]
    puts "----#{params[:iSortCol_0].to_i}"
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
