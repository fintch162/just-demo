class OnlinePaymentsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: PaymentNotification.count,
    iTotalDisplayRecords: payment_notifications.total_entries,
    aaData: data
   }
  end

private
  def data
    @payment_notifications = payment_notifications
    puts"<-----------payment_notifications.count--------------#{@payment_notifications.count}-------------#{@payment_notifications.first.inspect}----------->"
    # manual_payment_limk = link_to("REF #{payment_notification.job_ref}",  @view.manage_job_path(:id => payment_notification.job_ref) , :target => "_blank")
    cnt=0
    @payment_notifications.to_a.map do |payment_notification|
      cnt=cnt+1
      @manual_payment = ManualPayment.find_by(local_payment_id: payment_notification.id.to_s)
      puts"<-------------#{@manual_payment.inspect}----------------->"
      # if payment_notification.payment_date.blank?
        payment_date = link_to(payment_notification.created_at.strftime("%d %b %Y -  %I:%M %p"), @view.manage_online_payment_path(payment_notification))
      # else
        # payment_date = link_to(payment_notification.payment_date.strftime("%d %b %Y")+ " - " + payment_notification.pay_time.strftime("%I:%M %p"), @view.manage_online_payment_path(payment_notification))
      # end

      if !payment_notification.invoice_id.blank?
        @invoice_link = link_to(payment_notification.invoice_id,  @view.manage_freshbook_invoice_path(:online_payments_invoice_id => payment_notification.invoice_id), :target => "_blank")
      else
        @invoice_link = ""
      end

      if payment_notification.job_ref.blank?
        @job_ref_link = "--"
      else
        @job_ref_link = link_to("REF #{payment_notification.job_ref}",  @view.manage_job_path(:id => payment_notification.job_ref))
      end

      if payment_notification.status == "paid"
        payment_notification_status = "Completed"
      elsif payment_notification.status == "Added"
        payment_notification_status = "Paid"
      else
        payment_notification_status = payment_notification.status
      end
      if payment_notification.status != "Rejected" && payment_notification.status != "Completed" && !@manual_payment 
          add_payment_link = link_to "Add Payment", @view.manage_save_online_payments_to_manual_payments_path(payment_notification.id), :class => "addPayment"
      else
        add_payment_link = ""
      end

      if @manual_payment && !@manual_payment.manual_transaction_id.nil? && @manual_payment.manual_transaction_id != ""
        transaction_id=@manual_payment.manual_transaction_id
      else
        transaction_id=  '-'
      end

      [
        # payment_notification.id.to_s,
        cnt,
        # transaction_id,
        payment_date,
        @invoice_link,
        @job_ref_link,
        payment_notification_status,
        # @manual_payment && !@manual_payment.payment_id.nil? ? link_to(@manual_payment.payment_id, @view.manage_manual_payment_path(@manual_payment.id)): '-',
        # @manual_payment ? link_to(@manual_payment.local_payment_id, @view.manage_manual_payment_path(@manual_payment.id)): '-',
        payment_notification.amount,
        payment_notification.paid_by,
        add_payment_link
      ]
    end
  end
  def fetch_payment_notifications
    status = ["Completed", "Paid", "paid", "completed", "Added", "added"]
    # payment_notifications = PaymentNotification.order("#{sort_column} #{sort_direction}").where("status IN (?)",  status)
    payment_notifications = PaymentNotification.all.order("created_at DESC").order("#{sort_column} #{sort_direction}")
    if params[:iDisplayLength].to_i > 0 
      payment_notifications = payment_notifications.page(page).per_page(per_page)
    else
      payment_notifications = payment_notifications.page(1).per_page(payment_notifications.count)
    end

    if params[:sSearch].present? && params[:status] != "New"
      payment_notifications = payment_notifications.where("invoice_id::text LIKE ('%'::text || :search)
                      or job_ref::text LIKE ('%'::text || :search)
                      or status::text LIKE ('%'::text || :search)
                      or amount::text LIKE ('%'::text || :search)
                      or paid_by::text LIKE ('%'::text || :search)
                      ",search: "%#{params[:sSearch]}%")

    elsif (params[:status]=="New") || (!params[:sSearch].present? && params[:status] != 'All' && params[:status] == "")
      @manual_local_id= ManualPayment.where.not(:local_payment_id=> nil).where.not(:local_payment_id=> '').pluck("local_payment_id").uniq
      payment_notifications=payment_notifications.where("id NOT IN (?)",@manual_local_id).where(:status=>"Paid")

    # elsif !params[:sSearch].present? && params[:status] != 'All'
    #   puts"<--------#{params[:status]}-----------------#{params[:sSearch]}-----page load----------in all----------->"
    #   payment_notifications = payment_notifications.where("status IN (?)", ["Paid", "paid"])
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