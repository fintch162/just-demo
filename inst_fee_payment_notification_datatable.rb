class InstFeePaymentNotificationDatatable
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
      @fee_payment_notifications.to_a.map.each_with_index do |payment_notifications,index|  
        student = payment_notifications.fee.instructor_student 
        group_class = student.try(:group_classes).try(:last)
        [
          index + 1,
          payment_notifications.created_at.strftime("%Y-%-m-%d"),
          group_class.present? ? link_to(student.student_name,@view.instructor_instructor_student_path(student, :gp => group_class.id)): link_to(student.student_name,@view.instructor_instructor_student_path(student.id)), 
          group_class.present? ? link_to(group_class.short_heading,@view.instructor_group_class_view_add_more_months_path(group_class)) : "No Group Class",
          payment_notifications.fee.monthly_detail.strftime("%b-%Y"),
          payment_notifications.amount,
          payment_notifications.status,
          payment_notifications.paid_by
        ]
      end
    end

    def fetch_fee_payment_notifications
      fee_payment_notifications = Instructor.find(params[:instructor_id]).fee_payment_notifications.order("created_at DESC")
      puts"-----------#{fee_payment_notifications}----------------------------"
      ids = fee_payment_notifications.map {|p| p.id}
      fee_payment_notifications = FeePaymentNotification.where(id: ids,status: 'Paid')
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

      if params[:sSearch]== ""
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
        if params[:student_name].present?
          @instructor_student_ids=InstructorStudent.where("LOWER(student_name) LIKE ?","%#{params[:student_name].downcase}%").ids
          fee_ids = Fee.where("instructor_student_id IN (?) " , @instructor_student_ids).ids
          fee_payment_notifications = fee_payment_notifications.where(fee_id: fee_ids)
        end
      end
      # .per_page(fee_payment_notifications.count)
      # .order("#{sort_column} #{sort_direction}")
      if params[:iSortCol_0] == "0"
        fee_payment_notifications = fee_payment_notifications.order("created_at DESC")
      else
        fee_payment_notifications.order("#{sort_column} #{sort_direction}")
      end
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
      # columns = %w[created_at fee_id amount paid_by status name]
      columns = %w[created_at name class fee_for amount status paid_by]
      columns[params[:iSortCol_0].to_i - 1]
    end
    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end