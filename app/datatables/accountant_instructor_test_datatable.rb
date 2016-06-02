class AccountantInstructorTestDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: AwardTestPaymentNotification.count,
    iTotalDisplayRecords: award_test_payment_notifications.count,
    aaData: data
   }
  end

  private
    def data
      @award_test_payment_notifications = award_test_payment_notifications  
      @fetch_payment_process_data=SsaPaymentProcessFee.check_data  
      @award_test_payment_notifications.to_a.map.each do |payment_notifications|  
        
        @payment_process_data=0
        if payment_notifications.status == "Paid"
          if @fetch_payment_process_data
            @check_payment_name = SsaPaymentProcessFee.check_payment_name(payment_notifications.paid_by,payment_notifications.created_at.strftime("%Y-%m-%d"))
            if @check_payment_name.present?
              if @check_payment_name.class==Array
                @payment_process_data=0
              else
                puts"--#{payment_notifications.created_at.strftime("%Y-%m-%d")}--------#{@check_payment_name.inspect}---------------"
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
          payment_notifications.award_test_id,
          payment_notifications.amount,
          @payment_process_data.to_d,
          payment_notifications.instructor_student.present? ? payment_notifications.instructor_student.student_name : "",
          payment_notifications.paid_by,
          payment_notifications.status,
          payment_notifications.instructor_student.present? ? payment_notifications.instructor_student.admin_user.name : ""
        ]
      end
    end

    def fetch_award_test_payment_notifications
      award_test_payment_notifications = AwardTestPaymentNotification.includes(:instructor_student).all.order("created_at DESC")
      # puts"------fjhiewfjhewfrjhnoewk------------#{award_test_payment_notifications.count}-------------------------"
      # exit
      # .per_page(award_test_payment_notifications.count)
      # .order("#{sort_column} #{sort_direction}")

      if params[:iDisplayLength] == "-1"
        award_test_payment_notifications = award_test_payment_notifications.page(1).per_page(award_test_payment_notifications.count)
      else
        award_test_payment_notifications = award_test_payment_notifications.page(page).per_page(per_page)
      end

      if params[:sSearch].present? && params[:sSearch] != "undefined"

        award_test_payment_notifications=award_test_payment_notifications.where( "LOWER(paid_by) LIKE :search 
                                                                  or LOWER(status) LIKE :search  
                                                                  or '%'||amount||'%' LIKE :search 
                                                                  or '%'||award_test_id||'%' LIKE :search", search: "%#{params[:sSearch].downcase}%")
      end
      if params[:sSearch]== "undefined"
        field_list=["paid_by","status"]
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

        date_flag=false
        if params[:start_date].present?
          date_flag=true
          start_date=params[:start_date].to_date
        else
          start_date=award_test_payment_notifications.last.created_at.to_date
        end

        if params[:end_date].present?
          date_flag=true
          end_date=params[:end_date].to_date
        else
          end_date=Date.today
        end

        award_test_payment_notifications = award_test_payment_notifications.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if date_flag
        if str
          award_test_payment_notifications = award_test_payment_notifications.where("#{str}")
        end

        if params[:instructor].present? || params[:instructor] != ""
          @instructor_student_ids=Instructor.find(params[:instructor]).instructor_students.pluck(:id)
          award_test_payment_notifications = award_test_payment_notifications.where("instructor_student_id IN (?) " , @instructor_student_ids)
        end
      end
      award_test_payment_notifications
    end

    def award_test_payment_notifications
      @award_test_payment_notifications ||= fetch_award_test_payment_notifications
    end

    def page
      params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      # columns = %w[created_at invoice_id status amount paid_by]
      columns[params[:iSortCol_0].to_i]
    end
    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end