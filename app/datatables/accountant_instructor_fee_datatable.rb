class AccountantInstructorFeeDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: FeePaymentNotification.count,
    iTotalDisplayRecords: fee_payment_notifications.count,
    aaData: data
   }
  end
  private
    def data
      @fee_payment_notifications = fee_payment_notifications  
       @fetch_payment_process_data=SsaPaymentProcessFee.check_data 
      @fee_payment_notifications.to_a.map.each do |payment_notifications|  
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

        @instructor=payment_notifications.fee.instructor_student.admin_user if payment_notifications.fee_id? && payment_notifications.fee.present?
        [
          payment_notifications.created_at.strftime("%d %b %Y"),
          payment_notifications.fee_id,
          payment_notifications.amount,
          @payment_process_data.to_d,
          payment_notifications.paid_by,
          payment_notifications.status,
          @instructor.name
        ]
      end
    end

    def fetch_fee_payment_notifications
      fee_payment_notifications = FeePaymentNotification.all.order("created_at DESC")

      if params[:iDisplayLength] == "-1"
        fee_payment_notifications = fee_payment_notifications.page(1).per_page(fee_payment_notifications.count)
      else
        fee_payment_notifications = fee_payment_notifications.page(page).per_page(per_page)
      end

      if params[:sSearch].present? && params[:sSearch] != "undefined"

        fee_payment_notifications=fee_payment_notifications.where( "LOWER(paid_by) LIKE :search 
                                                                  or LOWER(status) LIKE :search  
                                                                  or '%'||amount||'%' LIKE :search 
                                                                  or '%'||fee_id||'%' LIKE :search", search: "%#{params[:sSearch].downcase}%")
      end

      if params[:sSearch]== "undefined"
        field_list=["paid_by","status","amount"]
        str=""
        cnt=0
        if params[:paid_by].present? && params[:paid_by] != ""
          str += field_list[0] + " = " + "'" + params[:paid_by] + "'"
          cnt=1
        end
        if params[:status].present? && params[:status] != ""
          if cnt !=0
            str+= " AND "
          end
          cnt=1
          str += field_list[1] + " = " + "'"  + params[:status] + "'"
        end
        if params[:amount].present? && params[:amount] != ""
          if cnt != 0
            str += " AND " 
          end
          cnt=1
          str += field_list[2] + " = " +  "'"  + params[:amount] + "'"
        end

        date_flag=false
        if params[:start_date].present?
          date_flag=true
          start_date=params[:start_date].to_date
        else
          start_date=fee_payment_notifications.last.created_at.to_date
        end

        if params[:end_date].present?
          date_flag=true
          end_date=params[:end_date].to_date
        else
          end_date=Date.today
        end

        fee_payment_notifications = fee_payment_notifications.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if date_flag

        if str
          fee_payment_notifications = fee_payment_notifications.where("#{str}")
        end

        if params[:instructor].present? || params[:instructor] != ""
          @instructor_fee_id=Instructor.find(params[:instructor]).fees.pluck(:id)
          fee_payment_notifications = fee_payment_notifications.where("fee_id IN (?) " , @instructor_fee_id)
        end
      end
      # .per_page(fee_payment_notifications.count)
      # .order("#{sort_column} #{sort_direction}")
      puts"---------------#{fee_payment_notifications.inspect}-----------------------------"
      fee_payment_notifications
    end

    def fee_payment_notifications
      @fee_payment_notifications ||= fetch_fee_payment_notifications
    end

    def page
      params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[created_at fee_id amount paid_by status name]
      columns[params[:iSortCol_0].to_i]
    end
    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end