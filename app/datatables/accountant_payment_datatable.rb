class AccountantPaymentDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: ManualPayment.count,
    iTotalDisplayRecords: manual_payment.count,
    aaData: data
   }
  end

private
  def data
    @manual_payment = manual_payment
    cnt=0
    @manual_payment.to_a.map do |manual_payment|
      cnt=cnt+1
      [
        cnt,
        manual_payment.created_at.strftime("%d %b %Y"),
        manual_payment.job_id,
        manual_payment.job_status? ? manual_payment.job_status : '-',
        manual_payment.referral? ? manual_payment.referral : '-' ,
        manual_payment.balance? ? manual_payment.balance : '-',
        manual_payment.amount? ? manual_payment.amount : '-' ,
        manual_payment.payment_method? ? manual_payment.payment_method : '-',
        manual_payment.goggles_status? ? manual_payment.goggles_status : '-',
        manual_payment.description? ? manual_payment.description : '-',
        manual_payment.invoice_number? ? manual_payment.invoice_number : '-'
      ]
    end
  end
  def fetch_manual_payment
    # status = ["Completed", "Paid", "paid", "completed", "Added", "added"]
    manual_payment = ManualPayment.all.order("created_at DESC")
    # .order("#{sort_column} #{sort_direction}")
    if params[:iDisplayLength].to_i > 0 
      manual_payment = manual_payment.page(page).per_page(per_page)
    else
      manual_payment = manual_payment.page(1).per_page(manual_payment.count)
    end

    if params[:sSearch].present? && params[:sSearch] != "undefined" 
      manual_payment = manual_payment.where("'%'||job_id||'%' LIKE :search
                                          or LOWER(job_status) LIKE :search
                                          or '%'||referral||'%' LIKE :search
                                          or '%'||balance||'%' LIKE :search
                                          or '%'||amount||'%' LIKE :search
                                          or LOWER(payment_method) LIKE :search
                                          or LOWER(goggles_status) LIKE :search
                                          or LOWER(description) LIKE :search
                                          or '%'||invoice_number||'%' LIKE :search ",search: "%#{params[:sSearch].downcase}%")
    end
    if params[:sSearch]== "undefined"
      field_list=["job_id","job_status"]
      cnt=0
      str=""
      if params[:job_id].present? && params[:job_id] != ""
        str += field_list[0] + " = " + params[:job_id]
        cnt=1
      end
      if params[:status].present? && params[:status] != ""
        if cnt!=0
          str += " AND "
        end
        cnt=1
        str += field_list[1] + " = " + "'" + params[:status] + "'"
      end

      date_flag=false
      if params[:start_date].present?
        date_flag=true
        start_date=params[:start_date].to_date
      else
        start_date=manual_payment.last.created_at.to_date
      end

      if params[:end_date].present?
        date_flag=true
        end_date=params[:end_date].to_date
      else
        end_date=Date.today
      end
      manual_payment=manual_payment.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if date_flag

      puts"-----------------#{str}-------------------------"

      if str
        manual_payment = manual_payment.where("#{str}")
      end
    end
    manual_payment
  end

  def manual_payment
    @manual_payment ||= fetch_manual_payment
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[created_at invoice_id status amount paid_by]
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end