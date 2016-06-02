class AccountantCoordinatorDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: PaymentNotification.count,
    iTotalDisplayRecords: payment_notifications.count,
    aaData: data
   }
  end

private
  def data
    @payment_notifications = payment_notifications
    @fetch_payment_process_data=SsaPaymentProcessFee.check_data
    @payment_notifications.to_a.map.each do |payment_notifications|
      @payment_process_data = 0
      if payment_notifications.status == "Paid"
      if @fetch_payment_process_data
        @check_payment_name = SsaPaymentProcessFee.check_payment_name(payment_notifications.paid_by,payment_notifications.created_at.strftime("%Y-%m-%d"))
        if @check_payment_name.present?
          if @check_payment_name.class==Array
            @payment_process_data=0
          else
            @payment_process_data=((payment_notifications.amount*@check_payment_name.processing_fee)/100)+@check_payment_name.transaction_fee 
          end
        else
          @payment_process_data = 0
        end
      else
        @payment_process_data = 0
      end
      end

      [
        payment_notifications.created_at.strftime("%d %b %Y"),
        payment_notifications.invoice_id,
        payment_notifications.amount,
        @payment_process_data.to_d,
        payment_notifications.paid_by,
        payment_notifications.status
      ]
    end
  end
  def fetch_payment_notifications
    payment_notifications = PaymentNotification.all.order("created_at DESC")
    
    if params[:iDisplayLength]== "-1"
      payment_notifications = payment_notifications.page(1).per_page(payment_notifications.count)
    else
      payment_notifications = payment_notifications.page(page).per_page(per_page)
    end

    if params[:sSearch].present? && params[:sSearch] != "undefined"

      payment_notifications=payment_notifications.where("LOWER(paid_by) LIKE :search 
                                                      or LOWER(status) LIKE :search 
                                                      or '%' ||amount||'%' LIKE :search 
                                                      or '%'||invoice_id||'%' LIKE :search",search: "%#{params[:sSearch].downcase}%")
    end

    if params[:sSearch] == "undefined"
      field_list=["paid_by" ,"amount","invoice_id","status"]
      str=""
      cnt=0
      if params[:paid_by].present? && params[:paid_by] != ""
        str += field_list[0] + " = " + "'" + params[:paid_by] + "'"
        cnt=1
      end
      if params[:amount].present? && params[:amount] != ""
        if cnt!=0
          str += " AND "
        end
        cnt=1
        str += field_list[1] + " = " + "'" + params[:amount] + "'"
      end
      if params[:invoice_id].present? && params[:invoice_id] != ""
        if cnt!=0
          str += " AND "
        end
        cnt=1
        str += field_list[2] + " = " + "'" + params[:invoice_id] + "'"
      end
      if params[:status].present? && params[:status] != ""
        if cnt!=0
          str += " AND "
        end
        cnt=1
        str += field_list[3] + " = " + "'" + params[:status] + "'"
      end

      date_flag=false
      if params[:start_date].present?
        date_flag=true
        start_date=params[:start_date].to_date
      else
        start_date=payment_notifications.last.created_at.to_date
      end

      if params[:end_date].present?
        date_flag=true
        end_date=params[:end_date].to_date
      else
        end_date=Date.today
      end

      payment_notifications = payment_notifications.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if date_flag

      if str
        payment_notifications = payment_notifications.where("#{str}")
      end
    end

    payment_notifications
  end

  def payment_notifications
    @payment_notifications ||= fetch_payment_notifications
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