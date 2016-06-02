class FreshbooksDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
    @api_setting = ApiSetting.first
    freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    freshbook_invoices = freshbookconnection.invoice.list :page => 1, :per_page => 100
    @freshbook_invoices = freshbook_invoices.to_json
    @total_record = @freshbook_invoices["invoices"]["total"].to_i
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: @total_record,
    iTotalDisplayRecords: jobs.length,
    aaData: data
   }
  end



private
  def data
    @jobs = jobs
    @jobs.to_a.map do |invoice|
      @job_ref = invoice['po_number']
      [
        invoice['number'],
        invoice['organization'],
        invoice['updated'].to_date.strftime("%d/%m/%Y"),
        invoice['amount'],
        invoice['status'],
        "Ref "+@job_ref
      ]
    end
  end
  def fetch_jobs
      @freshbook_invoices =JSON.parse(@freshbook_invoices)["invoices"]
      @total = @freshbook_invoices["total"].to_i
      @job_freshbook_invoices = []
      puts "<--------#{@freshbook_invoices["invoice"]}--------->"
      @freshbook_invoices["invoice"].each do |p| 
          @job_freshbook_invoices << p
      end  
    jobs = @job_freshbook_invoices
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
  columns = %w[created_at id job_status class_type age_group venue_id lead_name]
  columns[params[:iSortCol_0].to_i]
end
def sort_direction
  params[:sSortDir_0] == "desc" ? "desc" : "asc"
end

end