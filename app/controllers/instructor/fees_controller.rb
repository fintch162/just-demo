class Instructor::FeesController < Instructor::BaseController
  before_action :set_fee, only: [:edit, :update, :destroy]
  before_action :check_user_permission, only: [ :new, :update, :edit, :destroy, :create ] 

  def new
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @fee = @instructor_student.fees.build
  end

  def create
    logger.info"<--------------#{params}----------------->"
    if params[:fee_id].present?
      @fee = Fee.find(params[:fee_id])
      @fee.update(amount: params[:fee][:amount],payment_status: params[:fee][:payment_status],payment_date: params[:fee][:payment_date])
      @group_class = params[:group_class] if params[:group_class].present?
      @instructor_student = InstructorStudent.find(params[:instructor_student_id])
      respond_to do |format|
        format.js
        format.html { redirect_to instructor_instructor_student_path(@instructor_student)}
      end
    else
      @show_amount=params[:show_amount]
      @m = fee_params
      @instructor_student = InstructorStudent.find(params[:instructor_student_id])
      if !@m[:monthly_detail].blank?
        @m[:monthly_detail] = change_date_format(@m[:monthly_detail])
        @fee = @instructor_student.fees.find_by(monthly_detail: @m[:monthly_detail])
        # @m[:monthly_detail]  = '1 '.to_s + @m[:monthly_detail].gsub("-", " ")
        # @m[:monthly_detail] = Date.parse(@m[:monthly_detail])
      end
      @group_class = params[:group_class] if params[:group_class].present?
      if @fee.present?
        @fee.update(@m)
      else
        @fee = @instructor_student.fees.create(@m)
      end
      if @fee.save
        @fee.update(instructor_id: current_admin_user.id)
        respond_to do |format|
          format.js
          format.html { redirect_to instructor_instructor_student_path(@instructor_student)}
        end
      end
    end
    # @fee.update_attributes(:monthly_detail => @n)
  end

  def edit
  end

  def destroy
    @fee.destroy
    @student = InstructorStudent.find(params[:instructor_student_id]) if params[:instructor_student_id].present?
    @group_class = params[:group_class] if params[:group_class].present?
    respond_to do |format|
      format.js
      format.html { redirect_to instructor_instructor_student_path(params[:instructor_student_id]) }
    end
    # if params[:isRemove]
    #   respond_to :js
    # else
    # end
  end

  def update
    logger.info"<--------------#{params}----------------->"
    @show_amount=params[:show_amount]
    if params[:instructor_student_id]
      @student = InstructorStudent.find(params[:instructor_student_id])
    end
    @group_class = params[:group_class] if params[:group_class]

    @m = fee_params
    @m[:monthly_detail]  = change_date_format(@m[:monthly_detail]) if @m[:monthly_detail].present?

    @fee.update(@m)
    respond_to do |format|
      format.js
      format.html { redirect_to instructor_instructor_student_path(@fee.instructor_student_id)}
    end
    # respond_to do |format|
    #   format.html { redirect_to instructor_instructor_student_path(@fee.instructor_student_id)}
    # end
  end

  def quick_add_fee
    @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @instructor_student = nil
    @date = nil
    if params[:search]
      @instructor_student_ids = current_admin_user.instructor_students.pluck(:id)
      if @instructor_student_ids.include?(params[:search].to_i)
        @date = params[:date_payment]
        @instructor_student = current_admin_user.instructor_students.find(params[:search])
      else
        logger.info "<------No student--------->"
        @instructor_student = "No Student found"
      end
    end
  end
  def bulk_invoice_month_selection
    @student_ids = params[:student_ids]
    @group_class_id = params[:group_class]
    @due_date = params[:due_date] if params[:due_date].present?
    @monthly_detail = params[:monthly_detail] if params[:monthly_detail].present?
    # instructor_bulk_invoice_month_selection_path
  end
  def bulk_invoice_detail
    @due_date = Date.parse(params[:due_date]).strftime('%d %b %Y') rescue nil
    @group_class_id = params[:group_class]
    @student_ids = params[:student_ids]
    @students = InstructorStudent.unpaid_students(params[:student_ids],'01 ' + params[:monthly_detail])
    @monthly_detail = Date.parse(params[:monthly_detail]).strftime('%b %Y') rescue nil
    @monthly_detail_params=params[:monthly_detail] 
    @due_date_params=params[:due_date]
  end
  def set_bulk_invoice
    @group_class = GroupClass.find(params[:group_class])
    @students = InstructorStudent.where(id: params[:student_ids].split(' ')).includes(:fees)
    @due_date = params[:due_date]
    @monthly_detail = '01 ' + params[:monthly_detail]
    InstructorStudent.set_bulk_invoice(@students.ids,@monthly_detail,@due_date,@group_class)
  end

  private
  def set_fee
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @fee = @instructor_student.fees.find(params[:id])
  end
  def fee_params
    params.require(:fee).permit(:payment_date,:course_type, :monthly_detail, :amount, :course_start, :course_end, :instructor_student_id, :instructor_id,:payment_mode,:payment_status,:due_date) rescue {}
  end
  def change_date_format(date)
    if date.count('-') > 1
      date = Date.parse(date)
    else
      date  = '1 '.to_s + date.gsub("-", " ")
      date = Date.parse(date)
    end
    return date
  end

end
     