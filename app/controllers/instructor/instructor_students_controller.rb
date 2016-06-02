class Instructor::InstructorStudentsController < Instructor::BaseController
	before_action :check_user_permission, only: [ :index, :new, :show, :update, :edit, :destroy, :create, :edit_awards_certificates] 
  before_action :set_instructor_student, only: [:show, :edit, :update, :destroy, :edit_awards_certificates, :save_additional_description_about_student]
  respond_to :js , :only => [:change_class_details,:change_student_details,:change_contact_details,:change_award_details, :filter_instructor_students_by_selected_award]
  before_action :check_hide_show_columns, only: [ :index, :add_more_months_fee, :add_more_months_fee_from_gp]

	def index
    logger.info "<-------#{params}----------->"
    # for hide fee/attendance from students tab we set as false if want to enable then remove below line.
    
    current_admin_user.more_or_less_months.find_by_table_name('instructor_students').update(fee_attendance: 'false') if current_admin_user.more_or_less_months.find_by_table_name('instructor_students')
    leftSideMonths = 1..6
    rightSideMonths = -6..-1 

    @previousMonths = []
    leftSideMonths.each do |n|
      @previousMonths << n.months.ago.to_date.strftime("%b-%y")
    end

    @nextMonths = []
    rightSideMonths.each do |n|
      @nextMonths << n.months.ago.to_date.strftime("%b-%y")
    end  

    @startMonth = (1.month.ago).strftime("%b-%y")
    @endMonth = (Date.today + 1.months).strftime("%b-%y")

    month = @endMonth.to_date.strftime("%m").to_i
    year = @endMonth.to_date.strftime("%Y").to_i
    # endDateCnt = days_in_month(month, year)
    endDateCnt = Time.days_in_month(month, year)
      
    @start_date_att = Date.parse "1 #{@startMonth.gsub("-", " ")}"
    @end_date_att = Date.parse "#{endDateCnt} #{@endMonth.gsub("-", " ")}"


    # Award unregistered student list 
    if params[:award_id]
      @unregistered_award = Award.find(params[:award_id])
      @instructor_student = current_admin_user.instructor_students.where(:is_deleted => false).pluck(:id)
      @instructor_student_awards_student_list = InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress LIKE (?) AND is_registered = false AND award_id = (?)", @instructor_student, 'ready_for', params[:award_id] ).pluck(:instructor_student_id)
      
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @instructor_student_awards_student_list)
      
    elsif params[:search].present?
      @instructor_student_name = current_admin_user.instructor_students.where(
                                              "LOWER(student_name) LIKE ?", "%#{params[:search].downcase}%" ).pluck(:id)
      @instructor_student_contact = StudentContact.where(
                                               "contact LIKE ? AND primary_contact = true", "%#{params[:search]}%" ).pluck(:instructor_student_id)
      @instructor_student_awards_student_list = @instructor_student_name + @instructor_student_contact
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @instructor_student_awards_student_list)
     
    elsif params[:columnField].present? || params[:columnField] == ''
      @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
      @hide_show_columns.update(:name => false , :contact => false,:ic_number => false,:date_of_birth => false,:join_date => false,:description => false,:ready_for => false ,:training_for => false,:registered_for => false ,:achieved => false ,:profile_pic => false )

      column_field = params[:columnField].gsub(/[-]/, '_').downcase
      column_field = column_field.gsub('profile_picture', 'profile_pic').gsub('joined_date','join_date')
      @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])

      @instructor_students = current_admin_user.instructor_students.where(:is_deleted => false)
      if params[:columnField] != ''
        column_field_s = column_field.split(',')
        column_field_s.each do |c|
          @hide_show_columns.update(c => true)
        end
      end  
      # if params[:fee_check].present?
      #   @startMonth = params[:start_month]
      #   @endMonth = params[:end_month]
      #   @instructor_students = current_admin_user.instructor_students.all
      #   @instructor_student_fee=current_admin_user.more_or_less_months.find_by_table_name(params[:tableName])
      #   logger.info"<---------------#{@instructor_student_fee.inspect}-------------------->"
      #   logger.info"<---------------#{params[:tableName]}-------------------->"

      #   if @instructor_student_fee.present?
      #     @instructor_student_fee.update_attributes(:start_month=>params[:start_month],:end_month=>params[:end_month],:fee_attendance=>"true")
      #   else
      #     @instructor_student_fee=MoreOrLessMonth.create(:table_name=>params[:tableName],:start_month=>params[:start_month],:end_month=>params[:end_month],:fee_attendance=>"true",:instructor_id=>current_admin_user.id)
      #     logger.info"<---------------#{@instructor_student_fee.inspect}-------------------->"
      #   end
      # else
        @instructor_student_fee=current_admin_user.more_or_less_months.find_by_table_name(params[:tableName])
        logger.info"<---------------#{@instructor_student_fee.inspect}-------------------->"
        if @instructor_student_fee.present?
          @instructor_student_fee.update_attributes(:fee_attendance=>"false")
        else
          @instructor_student_fee=MoreOrLessMonth.create(:table_name=>params[:tableName],:fee_attendance=>"false",:instructor_id=>current_admin_user.id)
        end
      # end
      # @instructor_students = current_admin_user.instructor_students.where(:is_deleted => false)
    elsif params[:fee_month]
      fee_month=params[:fee_month]
      unpaid_inst_student_ids = []
      group_class_ids=current_admin_user.group_classes.where(fee_type_id:FeeType.per_month_id).ids
      group_class_ids.each do |group_class|
        inst_student_ids=GroupClass.find(group_class).instructor_students.ids
        inst_student_ids.each do |student|
          if Fee.where(monthly_detail:fee_month, instructor_student_id:student).count == 0
            unpaid_inst_student_ids << student
          end
        end
      end 
      @instructor_students=current_admin_user.instructor_students.where("id IN (?)", unpaid_inst_student_ids.uniq)
    elsif params[:award_count]
      @current_instructor_students=current_admin_user.instructor_students.pluck(:id)
      logger.info"<----------------#{@current_instructor_students.inspect}------------------------>"
      @award_for_pass_student=InstructorStudentAward.where("instructor_student_id IN (?)",@current_instructor_students).where(status: "Pass").where(:award_id => params[:award_count]).pluck(:instructor_student_id)
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @award_for_pass_student)
    else
      @instructor_students = current_admin_user.instructor_students.where(:is_deleted => false)
    end
    # @group_class = current_admin_user.group_classes.find(params[:id])
    @active_students = 0
    @inactive_students = 0
    @instructor_students.each do |instructor_student|
      if instructor_student.group_classes.count != 0
        @active_students = @active_students + 1
      end
      if instructor_student.group_classes.count == 0
        @inactive_students = @inactive_students + 1
        @unregistered_student = InstructorStudentAward.where(:is_registered => false)
      end
    end

    instructor_student_awrd = InstructorStudentAward.where.not(award_progress: "")
    @achieved_awardIds = instructor_student_awrd.group_by { |t| t.award_progress }
    # @achieved_award_for_filter = achieved_awardIds.pluck("award_id")
    session[:group_class_id] = ""
    # print_student_list
    if params[:fee_check].present?
      logger.info"<----------if-------#{@startMonth}-------------------->"
      redirect_to instructor_add_more_months_fee_path(:start_month => @startMonth,:end_month=> @endMonth,:hide_show_columns=>@hide_show_columns)
    else
      add_more_months_fee
    end
  end

  def search_result
    @instructor_student_name = current_admin_user.instructor_students.where(
                                              "LOWER(student_name) LIKE ?", "%#{params[:search].downcase}%" ).pluck(:id)
    @instructor_student_contact = StudentContact.where(
                                             "contact LIKE ? AND primary_contact = true", "%#{params[:search]}%" ).pluck(:instructor_student_id)
    @instructor_student_awards_student_list = @instructor_student_name + @instructor_student_contact
    @instructor_students = current_admin_user.instructor_students.where("id IN (?) AND is_deleted = false", @instructor_student_awards_student_list)
    respond_to do |format|
      format.js {}
      format.html {}
    end
  end

  def print_student_list
    if params[:award_id]
      @unregistered_award = Award.find(params[:award_id])
      @instructor_student = current_admin_user.instructor_students.where(:is_deleted => false).pluck(:id)
      @instructor_student_awards_student_list = InstructorStudentAward.where("instructor_student_id IN (?) AND award_progress LIKE (?) AND is_registered = false AND award_id = (?)", @instructor_student, 'ready_for', params[:award_id] ).pluck(:instructor_student_id)
      @instructor_students = current_admin_user.instructor_students.where("id IN (?)", @instructor_student_awards_student_list)
    elsif params[:fee_month] || params[:award_count]
    else
      @instructor_students = current_admin_user.instructor_students.all
    end
    
    @active_students = 0
    @inactive_students = 0
    @group_classes =  current_admin_user.group_classes.order("day", "time")
     
    @instructor_students.each do |instructor_student|
      if instructor_student.group_classes.count != 0 
        @active_students = @active_students + 1
      end
      if instructor_student.group_classes.count == 0
        @inactive_students = @inactive_students + 1
      end
    end
  end

  def filter_instructor_students_by_selected_award
    @awardIds = params[:selectedAward]
    if !@awardIds.nil?
      @award_progress = ["achieved", "ready_for", "training_for"]
      @instructor_student_awards = InstructorStudentAward.where(:award_id => @awardIds).where("award_progress IN (?)", @award_progress)
      instructor_student_ids = @instructor_student_awards.pluck(:instructor_student_id)
      @instructor_student = current_admin_user.instructor_students.where(:id => instructor_student_ids)
      grp_class = []
      @grp = []
      @instructor_student.each do |instructor|
        if !grp_class.include?(instructor.group_classes)
          grp_class << instructor.group_classes
          instructor.group_classes.each do |group|
            @grp << group
          end
        end
      end
      @group_classes_f = grp_class
    end
  end

	def new
    if params[:gp]
      @group_class = GroupClass.find(params[:gp])
    else
      @group_class = ""
    end
		@instructor_student = current_admin_user.instructor_students.new
		@instructor_student.instructor_student_awards.build
    @instructor_student.student_contacts.build
    # @instructor_student.student_contacts.build
		@group_classes = current_admin_user.group_classes
		@day_list = current_admin_user.group_classes.pluck(:day).uniq
		# @group_classes = GroupClass.find_by_sql("SELECT time, FROM group_class GROUP BY day");
	end

	def create
    if params[:student_name].present? || params[:contact].present?
      logger.info "<-------#{params}----------->"
      @instructor_student = current_admin_user.instructor_students.new(:student_name => params[:student_name], :group_class_ids => params[:group_class_id],is_update: true)
      @instructor_student.student_contacts.new(:contact => params[:contact], :primary_contact => true)
      @instructor_student.save
      Award.all.each do |award|
        @instructor_student_award = award.instructor_student_awards.build(instructor_student_id: @instructor_student.id)
        @instructor_student_award.save
      end
      # respond_to do |format|
      #   format.js
      # end
     render :text => @instructor_student.id
    else
      @instructor_student = current_admin_user.instructor_students.new(instructor_student_params)
  		if @instructor_student.save
        Award.all.each do |award|
          @instructor_student_award = award.instructor_student_awards.build(instructor_student_id: @instructor_student.id)
          @instructor_student_award.save
        end
  			respond_to do |format|
  				# if session[:group_class_id] != ""
  				# 	format.html { redirect_to  instructor_group_class_view_path(session[:group_class_id])}
  				# else
        		format.js
            format.html { redirect_to instructor_instructor_students_path}
        	# end
      	end
      end
    end  
	end

	def edit
    #@instructor_student.student_contacts.build
		@group_classes = current_admin_user.group_classes
		@day_list = current_admin_user.group_classes.pluck(:day).uniq
	end

	def update
		@instructor_student.update(instructor_student_params)
		respond_to do |format|
      format.html { redirect_to instructor_instructor_student_path(@instructor_student)}
    end
	end

  def sort
    params[:instructor_student].each_with_index do |id, index|
      InstructorStudent.where(:id => id).each do |p|
        p.update position: index+1
      end
    end
    render nothing: true
  end

	def show
    @instructor_student = InstructorStudent.find(params[:id])
    logger.info("#{params}.......#{@instructor_student.inspect}.....")

    @gallery =@instructor_student.gallery
    logger.info("#{params}.......#{@gallery.inspect}.....")
    
    #@photos = @instructor_student.gallery.photos

    if @instructor_student.student_contacts == 0
      @instructor_student.student_contacts.build
    end

    # @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @instructor_student.instructor_student_awards.build
    if params[:gp]
      @group_class = GroupClass.find_by_id(params[:gp])
    else
      @group_class = @instructor_student.group_classes.first
    end
		@primary_contact = @instructor_student.student_contacts.where(:primary_contact => true)
		@contact = @instructor_student.student_contacts.where(:primary_contact => false)
    # items = ["training_for", "ready_for", "Training", "Ready"]
    # @trainning_ready_award = @instructor_student.instructor_student_awards.where("award_progress IN (?)", items)
    # achieved_a = ["achieved", "Achieved"]
    # @achieved_award = @instructor_student.instructor_student_awards.where("award_progress IN (?)", achieved_a)
    award_status = ["training_for", "ready_for", "Training", "Ready","achieved", "Achieved"]
    @ins_student_award = @instructor_student.instructor_student_awards.where("award_progress IN (?)", award_status).order("updated_at DESC")
    @day_list = current_admin_user.group_classes.pluck(:day).uniq
    @group_classes = current_admin_user.group_classes
    @student_view_url = ApiSetting.first.student_view_url  
    if !@student_view_url.present?
      @student_view_url = request.base_url
    end
    # @message_body = "Student : " + @instructor_student.student_name.titleize + "\r" + @student_view_url + "/student/" + @instructor_student.secret_token + "\r- Instructor " + current_admin_user.short_name.titleize
    @message_body = "<student_name>" + "\r" + "<student_link>"
    
    @instructor_student_contacts = @instructor_student.student_contacts.where.not(:contact => ["", nil])#.where.not(:relationship => ["", nil], :contact  => ["", nil])

    @instructor_student_award_array = @instructor_student.instructor_student_awards.pluck(:award_id)
    @award_array = Award.pluck(:id)
    @remaining_award = @award_array - @instructor_student_award_array

    status = [ "Confirmed","pending", "Pending","confirmed" ]
    @student_award_registered = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for", :is_registered => true).where("status IN (?)", status)
    # @instructors = Instructor.where("id != ?", current_admin_user.id).pluck(:name)
    @instructors = Instructor.where("id != ?", current_admin_user.id).pluck(:id)
    if @remaining_award.length > 0
      @remaining_award.each do |m|
        @instructor_student.instructor_student_awards.create(:award_id => m)
      end
    end
    #@instructorStudentAttendance = StudentAttendance.where(group_class_id: params[:gp], instructor_student_id: params[:id])
   
    @instructorStudentAttendance = StudentAttendance.where(instructor_student_id: params[:id])

    @isInTransfer = Transfer.where(instructor_student_id: @instructor_student).where.not(transfer_status: "Rejected").first
    @transferFrom = Transfer.where(new_student_id: params[:id]).where.not(transfer_status: "Rejected").first
    @transferTo = Transfer.where(instructor_student_id: @instructor_student).where(transfer_status: "Transferred").first
    @photos_tagged_in = @instructor_student.photo_tags


    @inst_messages=InstructorConversation.where("instructor_id = (?) AND phone_number IN (?)" , current_admin_user,@instructor_student_contacts.pluck(:contact))

    @fee = @instructor_student.fees.build #-------------for create invoice from fees tab

    # To get coaches who have active classes and that active classes have students
    active_classes = GroupClass.includes(:instructor_students).is_active
    @active_instructors = []
    active_classes.each do |active_class|
      @active_instructors <<  active_class.instructor if active_class.instructor_students.present?
    end
    @active_instructors.uniq!
    # logger.info"<------InstructorMessage--------------#{@inst_con.instructor_messages.inspect}---------------------------->"

#     gr_class = []
#     gp_time = []
#     @instructorStudentAttendance.each do |instr_stdn_attn|
      
#       logger.info".................................#{instr_stdn_attn.inspect}..........................."
      
#       @grpclas_id = instr_stdn_attn.group_class_id
#       logger.info".................................#{@grpclas_id}..........................."
      
#       @grpclas = GroupClass.find(@grpclas_id)
#       logger.info".................................#{@grpclas.inspect}..........................."
#       gr_class << @grpclas 
#       @grpclas_time = @grpclas.time 
#       logger.info".................................#{@grpclas_time.inspect}..........................."
#       gp_time << @grpclas_time
#     end
#     logger.info".................................#{gp_time.inspect}..........................."
#     logger.info".................................#{gr_class.inspect}..........................."
  
# @instructorStudentAttendance_time = StudentAttendance.where(instructor_student_id: params[:id]).order("@gp_time DESC")
#     # logger.info".................................#{ @a = @instructorStudentAttendance.last.group_class_id}..........................."
#     # logger.info".................................#{@grpclas = GroupClass.find(@a)}..........................."
#     # logger.info".................................#{@grpclas.time}..........................."
#     # exit
#   attendance_time = []
#   gr_class.each do |tm|
#     @attendance_time_1 = tm.time.strftime("%I:%M %p").to_s + " - " + (tm.time + tm.duration*60).strftime("%I:%M %p").to_s
#   attendance_time << @attendance_time_1
#   end
#   logger.info"//////////////////////............#{attendance_time.inspect}/////"
   # @attendance_time = @group_class.time.strftime("%I:%M %p").to_s + " - " + (@group_class.time + @group_class.duration*60).strftime("%I:%M %p").to_s
  end

	def destroy
		# @instructor_student.destroy
    @instructor_student.update is_deleted: true
		@instructor_student.group_classes.delete_all
    @instructor_student.update(group_id: nil)

    respond_to do |format|
      format.js
      format.html do
        # redirect_to instructor_instructor_students_path, :notice => "Student has been deleted successfully."
        redirect_to instructor_instructor_student_path(@instructor_student), :notice => "Student has been deleted successfully."
      end
    end 
	end

  def bulk_remove
    logger.info"---------------#{params}----------------------"
    @previous_class_ids = params[:bulk_remove_id].split(",").map { |s| s.to_i }
    @group_class_id = InstructorStudent.find(@previous_class_ids.first).group_classes.last.id
    @previous_class_ids.each do |id|
      @instructor_student = InstructorStudent.find(id)
      @instructor_student.update_attributes(group_id: nil)
      @instructor_student.student_group_class_histories.create(:group_class_id=>@group_class_id)
      @instructor_student.group_class_ids = []
    end
    redirect_to instructor_group_class_view_add_more_months_path(@group_class_id)
  end
  
  def countries
    @countries = ["Andorra","United Arab Emirates","Afghanistan","Antigua and Barbuda","Anguilla","Albania","Armenia","Angola","Antarctica","Argentina","American Samoa","Austria","Australia","Aruba","Ã…land","Azerbaijan","Bosnia and Herzegovina","Barbados","Bangladesh","Belgium","Burkina Faso","Bulgaria","Bahrain","Burundi","Benin","Saint BarthÃ©lemy","Bermuda","Brunei","Bolivia","Bonaire","Brazil","Bahamas","Bhutan","Bouvet Island","Botswana","Belarus","Belize","Canada","Cocos [Keeling] Islands","Congo","Central African Republic","Republic of the Congo","Switzerland","Ivory Coast","Cook Islands","Chile","Cameroon","China","Colombia","Costa Rica","Cuba","Cape Verde","Curacao","Christmas Island","Cyprus","Czechia","Germany","Djibouti","Denmark","Dominica","Dominican Republic","Algeria","Ecuador","Estonia","Egypt","Western Sahara","Eritrea","Spain","Ethiopia","Finland","Fiji","Falkland Islands","Micronesia","Faroe Islands","France","Gabon","United Kingdom","Grenada","Georgia","French Guiana","Guernsey","Ghana","Gibraltar","Greenland","Gambia","Guinea","Guadeloupe","Equatorial Guinea","Greece","South Georgia and the South Sandwich Islands","Guatemala","Guam","Guinea-Bissau","Guyana","Hong Kong","Heard Island and McDonald Islands","Honduras","Croatia","Haiti","Hungary","Indonesia","Ireland","Israel","Isle of Man","India","British Indian Ocean Territory","Iraq","Iran","Iceland","Italy","Jersey","Jamaica","Jordan","Japan","Kenya","Kyrgyzstan","Cambodia","Kiribati","Comoros","Saint Kitts and Nevis","North Korea","South Korea","Kuwait","Cayman Islands","Kazakhstan","Laos","Lebanon","Saint Lucia","Liechtenstein","Sri Lanka","Liberia","Lesotho","Lithuania","Luxembourg","Latvia","Libya","Morocco","Monaco","Moldova","Montenegro","Saint Martin","Madagascar","Marshall Islands","Macedonia","Mali","Myanmar [Burma]","Mongolia","Macao","Northern Mariana Islands","Martinique","Mauritania","Montserrat","Malta","Mauritius","Maldives","Malawi","Mexico","Malaysia","Mozambique","Namibia","New Caledonia","Niger","Norfolk Island","Nigeria","Nicaragua","Netherlands","Norway","Nepal","Nauru","Niue","New Zealand","Oman","Panama","Peru","French Polynesia","Papua New Guinea","Philippines","Pakistan","Poland","Saint Pierre and Miquelon","Pitcairn Islands","Puerto Rico","Palestine","Portugal","Palau","Paraguay","Qatar","RÃ©union","Romania","Serbia","Russia","Rwanda","Saudi Arabia","Solomon Islands","Seychelles","Sudan","Sweden","Singapore","Saint Helena","Slovenia","Svalbard and Jan Mayen","Slovakia","Sierra Leone","San Marino","Senegal","Somalia","Suriname","South Sudan","SÃ£o TomÃ© and PrÃ­ncipe","El Salvador","Sint Maarten","Syria","Swaziland","Turks and Caicos Islands","Chad","French Southern Territories","Togo","Thailand","Tajikistan","Tokelau","East Timor","Turkmenistan","Tunisia","Tonga","Turkey","Trinidad and Tobago","Tuvalu","Taiwan","Tanzania","Ukraine","Uganda","U.S. Minor Outlying Islands","United States","Uruguay","Uzbekistan","Vatican City","Saint Vincent and the Grenadines","Venezuela","British Virgin Islands","U.S. Virgin Islands","Vietnam","Vanuatu","Wallis and Futuna","Samoa","Kosovo","Yemen","Mayotte","South Africa","Zambia","Zimbabwe"]
    respond_to do |format|
      format.json {
        render json: @countries
      }
    end
  end
  
  def cancle_student_award
    logger.info"<-----------------#{params}------------------------>"
    @instructor_student_award=InstructorStudentAward.find(params[:id])
    @award=Award.find(params[:award_id])
    @instructor_student=InstructorStudent.find(params[:instructor_student])
  end

  def change_student_name
    @instructor_student = InstructorStudent.find(params[:id])
    student_name = params[:student_name]
    description = params[:additional_description]
    join_date = params[:join_date]
    @instructor_student.update(additional_description: description , student_name: student_name, join_date: join_date)
    
    # @instructor_student.save
    
    # description = params[:additional_description]
    # @instructor_student.update(additional_description: description)
  end

  def change_class_details
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student_exist=InstructorStudentGroupClass.find_by(:instructor_student_id=>params[:id],:group_class_id=>params[:group_class_ids])
    # unless @instructor_student_exist.present?
    #   @instructor_student.group_class_ids = params[:group_class_ids]
    #   @instructor_student.fee=params[:fee]
    #   @instructor_student.update(:group_id => nil)
    #   @instructor_student.save
    # end

    @previous = @instructor_student.group_class_ids

    if @instructor_student_exist.present?
      @instructor_student.fee=params[:fee]
    else
      logger.info"-----#{@instructor_student.inspect}--------------------"
      @instructor_student.group_class_ids = params[:group_class_ids]
      @instructor_student.fee=params[:fee]
      @instructor_student.update(:group_id => nil)
      @instructor_student.update(is_update: true)
    end
    if @previous != @instructor_student.group_class_ids
      StudentGroupClassHistory.create(:instructor_student_id=>params[:id],:group_class_id=>@previous.join(" ").to_i)
    end
    @instructor_student.save
  end

  def change_student_details
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student.update_attributes( :ic_number => params[:ic_number],:date_of_birth => params[:date_of_birth],:gender => params[:gender],:country => params[:country],:address => params[:address])
  end

  def change_contact_details
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student.update(instructor_student_params)
    @instructor_student.update(is_update: true)
    if !params[:deleted_contacts].blank?
      deleted_contacts = params[:deleted_contacts]
      deleted_contacts = deleted_contacts.split(",").map {|i| i.to_i}
      delete_contact = @instructor_student.student_contacts.find(deleted_contacts)
      delete_contact.each do |p|
        p.destroy
      end
    end
    # redirect_to instructor_update_google_contact_path(@instructor_student) 
    # render 'posts/show' or render :template => 'posts/show'
  end

  def change_award_details
    logger.info "<------#{params}---------->"
    logger.info "<------#{params[:instructor_student_award]}---------->"
    @instructor_student = InstructorStudent.find(params[:id])
    @instructor_student_award=@instructor_student.instructor_student_awards.find(params[:instructor_student_award][:instructor_student_award_id])
    logger.info "<------#{@instructor_student.instructor_student_awards.find(params[:instructor_student_award][:instructor_student_award_id]).inspect}---------->"
    @instructor_student_award.update_attributes(award_progress: params[:instructor_student_award][:award_progress] ,achieved_date: params[:instructor_student_award][:achieved_date])
    @award=Award.find(params[:instructor_student_award][:award_id])
    # exit
    # if !params[:deleted_awards].blank?
    #   deleted_awards = params[:deleted_awards]
    #   deleted_awards = deleted_awards.split(",").map {|i| i.to_i}
    #   deleted_award = @instructor_student.instructor_student_awards.find(deleted_awards)
    #   deleted_award.each do |p|
    #     p.destroy
    #   end
    # end
  end

  def edit_awards_certificates
    @instructor_student = current_admin_user.instructor_students.find(params[:id])
    @instructor_student.instructor_student_awards.build
  end

  def profile_upload
    @instructor_student = InstructorStudent.find(params[:id])
    file = params[:qqfile].is_a?(ActionDispatch::Http::UploadedFile) ? params[:qqfile] : params[:file]
    @instructor_student.profile_picture = file
    if @instructor_student.save
      render :json => @instructor_student.profile_picture
    end
  end

  def tansfer_out
    # instructor = Instructor.where("LOWER(name) LIKE :search",search: "%#{params[:instructorToTransfer].downcase}%").first
    instructor = Instructor.find(params[:instructor])
    instructor_student = params[:instructor_student]
    reason = params[:reason]
    @transfer = Transfer.create(instructor_id: current_admin_user.id,
                    transfer_to: instructor.id,
                    instructor_student_id: instructor_student,
                    reason: reason,
                    transfer_status: "Transferring")
    if params[:gp].present?
      redirect_to instructor_instructor_student_path(@transfer.instructor_student_id, :gp => params[:gp]), notice: "Transfer student is done."
    else
      redirect_to instructor_instructor_student_path(@transfer.instructor_student_id), notice: "Transfer student is done."
    end
  end


  def save_additional_description_about_student
    description = params[:additional_description]
    @instructor_student.update(additional_description: description)
  end

  def add_student_from_dashboard
    @m = JSON.parse(params[:total_param])
    @m.each do |m|
      if (m[0] == nil || m[0] == "") && (m[1] == nil || m[1] == "") && (m[2] == nil || m[2] == "") && (m[3] == nil || m[3] == "") && (m[4] == nil || m[4] == "") && (m[5] == nil || m[5] == "") && (m[6] == nil || m[6] == "")
      else
        m[4] = m[4].delete(' ') unless m[4].nil?
        @instructor_student = current_admin_user.instructor_students.create(:student_name => m[0], :ic_number => m[1], :date_of_birth => m[2], :join_date => m[3], :contact => m[4],:fee => m[5],:additional_description => m[6], is_update: true) 
        Award.all.each do |award|
          @instructor_student_award = award.instructor_student_awards.build(instructor_student_id: @instructor_student.id)
          @instructor_student_award.save
        end
        @n = InstructorStudentGroupClass.create(:group_class_id => params[:group_class_id], :instructor_student_id => @instructor_student.id)
        if m[4] != nil
          @student_contact = StudentContact.create(:relationship => "Myself", :contact => m[4], :instructor_student_id => @instructor_student.id, :primary_contact => true)
        end
      end
    end
    render :text => "done"
  end
  def add_more_months_fee

    leftSideMonths = 1..6
    rightSideMonths = -6..-1

    @previousMonths = []
    leftSideMonths.each do |n|
      @previousMonths << n.months.ago.to_date.strftime("%b-%y")
    end
    @nextMonths = []
    rightSideMonths.each do |n|
      @nextMonths << n.months.ago.to_date.strftime("%b-%y")
    end

    @instructor_students_fee=current_admin_user.more_or_less_months.find_by_table_name("instructor_students")
    logger.info"<------------#{@instructor_students_fee.inspect}------------------->"
    if params[:start_month].present?
      @startMonth = params[:start_month]
      @endMonth = params[:end_month]
      @hide_show_columns=HideShowColumn.find(params[:hide_show_columns])
      @instructor_students = current_admin_user.instructor_students.all
      @active_students = 0
      @inactive_students = 0
      @instructor_students.each do |instructor_student|
        if instructor_student.group_classes.count != 0
          @active_students = @active_students + 1
        end
        if instructor_student.group_classes.count == 0
          @inactive_students = @inactive_students + 1
        end
      end
    else
      if @instructor_students_fee.present?
        if @instructor_students_fee.fee_attendance==true
          @startMonth = @instructor_students_fee.start_month
          @endMonth = @instructor_students_fee.end_month
          @hide_show_columns=HideShowColumn.find(params[:hide_show_columns])
        end
      else
        @startMonth = (1.month.ago).strftime("%b-%y")
        @endMonth = (Date.today + 1.months).strftime("%b-%y")
      end
    end


    instructor_student_awrd = InstructorStudentAward.where.not(award_progress: "")
    @achieved_awardIds = instructor_student_awrd.group_by { |t| t.award_progress }

    month = @endMonth.to_date.strftime("%m").to_i
    year = @endMonth.to_date.strftime("%Y").to_i
    endDateCnt = Time.days_in_month(month, year)
    # endDateCnt = days_in_month(month, year)

    @start_date_att = Date.parse "1 #{@startMonth.gsub("-", " ")}"
    @end_date_att = Date.parse "#{endDateCnt} #{@endMonth.gsub("-", " ")}"



    session[:group_class_id] = ""
    print_student_list
  end

  def restore_student
    @instructor_student = current_admin_user.instructor_students.find(params[:id])
    @instructor_student.update(is_deleted: false)

    redirect_to instructor_instructor_student_path(@instructor_student)
  end

  def student_timing
    @latest_lesson_date = Date.today
    if params[:instructor_student].present?
      if params[:group_class].present?
        grp_class = GroupClass.find(params[:group_class])
        if grp_class.day > Date.today.wday 
          @latest_lesson_date = Date.parse(Date::DAYNAMES[grp_class.day]) - 7.days
        else
          @latest_lesson_date = Date.parse(Date::DAYNAMES[grp_class.day])
        end
      end
      @instructor_student=InstructorStudent.find(params[:instructor_student])
      @timing=Timing.find(params[:id])
      @instructor_student_timing=InstructorStudentTiming.new
    else
      @instructor_student_timing=InstructorStudentTiming.find(params[:id])
    end
  end


 	private

	def set_instructor_student
    if admin_user_signed_in?
      @instructor_student = current_admin_user.instructor_students.find(params[:id])
    else
      redirect_to manage_root_path
    end
  end

  # Only allow a trusted parameter "white list" through.
  def instructor_student_params
    params.require(:instructor_student).permit(:is_deleted, :reason_to_transfer, :additional_description, :student_name, :ic_number, :address, :country,
                                               :profile_picture, :age, :gender, :contact, :job_id, :date_of_birth, :join_date,:admin_user_id, :group_class_id, :is_update,
                                               :award_id, group_class_ids: [], :instructor_student_awards_attributes => [:id, :award_progress, :award_id, :achieved_date, :comment, :_destroy],
                                               :student_contacts_attributes => [:id, :relationship,:name,:contact, :primary_contact, :email,:_destroy, :group_id]) rescue {}
  end

  def check_hide_show_columns
    @hide_show_columns = current_admin_user.hide_show_columns.find_by_table_name("instructor_students")
    if @hide_show_columns.blank?
      @hide_show_columns = current_admin_user.hide_show_columns.create(table_name: "instructor_students", name: "true", contact: "true",
                                ic_number: "true", date_of_birth: "true", join_date: "true",
                                description: "true", ready_for: "true", training_for: "true",
                                registered_for: "true", achieved: "true", profile_pic: "true")
    end
  end

  def days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end
end