class Manage::AwardTestsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Award Test", :manage_award_tests_path
  before_action :check_user_permission, only: [ :new, :create, :index ] 
  
  def index
    # @past_award_tests = AwardTest.past_award_tests.order("test_date desc , test_time")
    # @comming_award_tests = AwardTest.comming_award_tests.order("test_date desc , test_time")
    str = ""
    cnt = 0
    @award_tests = AwardTest.order("test_date desc , test_time")
    @instructor_id = params[:instructor]
    session[:search_key] = ""
    if params[:from]
      field_list = ["test_date", 'award_id', 'venue_id', 'assessor']
      if params[:from].present? || params[:to].present?
        if params[:to].present?
          start_date = params[:from].to_date
          end_date = params[:to].to_date
          @award_tests = @award_tests.where(test_date:  start_date..end_date)
        else
          start_date = params[:from].to_date
          @award_tests = @award_tests.where("test_date >= ?", start_date)
        end
      end
      if params[:award].present? && params[:award] != ""
        str += field_list[1] + " = " + "'"+params[:award]+"'"
        cnt =1
      end
      if params[:venue].present? && params[:venue] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[2] + " = " + "'"+params[:venue]+"'"
      end
      if params[:organiser].present? && params[:organiser] != ""
        if cnt != 0
          str += " AND "
        end
        cnt = 1
        str += field_list[3] + " = " + "'"+params[:organiser]+"'"
      end 
      if !str.empty?
        @award_tests = @award_tests.where(str)
        if params[:student_name].present? && params[:student_name] !=""
          session[:search_key] = params[:student_name]
          award_tests_ids =InstructorStudentAward.award_test_ids_by_student(params[:student_name])
          @award_tests = @award_tests.where('id IN (?)',award_tests_ids)
        end
        award_id = @award_tests.pluck(:award_id)
        @test_id = @award_tests.pluck(:id)
        @award = Award.where("id IN (?)", award_id)
        @date = params[:from]
      else
        award_id = @award_tests.pluck(:award_id)
        if params[:student_name].present? && params[:student_name] !=""
          session[:search_key] = params[:student_name]
          award_tests_ids =InstructorStudentAward.award_test_ids_by_student(params[:student_name].downcase)
          @award_tests = @award_tests.where('id IN (?)',award_tests_ids)
        end
        @test_id = @award_tests.pluck(:id)   
        @award = Award.where("id IN (?)", award_id)
        @date = Date.today.strftime('%d %B %Y')
      end
      if params[:instructor].present? && params[:instructor] != ""
        @instr_stundt_ids = InstructorStudent.where("admin_user_id IN (?)", @instructor_id ).pluck(:id)
        present_award_test = []
        @award_tests.each do |award_test|
          @m = award_test.instructor_student_awards.where("instructor_student_id IN (?)", @instr_stundt_ids)
          if @m.count > 0
            present_award_test << award_test.id
          end
        end
        @award_tests = @award_tests.where("id IN (?)", present_award_test)
        award_id = @award_tests.pluck(:award_id)
        @test_id = @award_tests.pluck(:id)
        @award = Award.where("id IN (?)", award_id)
      end
      if params[:payment].present? && params[:payment] != ""
        logger.info"--#{params[:payment]}------payment-------------"
        inst_payment=AwardTestPaymentNotification.where("award_test_id IN (?)",@award_tests.ids)
        if params[:payment]=="Paid"
          inst_payment=inst_payment.where(status: "Paid").pluck(:award_test_id)
          # inst_payment=AwardTestPaymentNotification.where("award_test_id IN (?) AND status = ? ",@award_tests.ids,params[:payment]).pluck(:award_test_id)
        else
          inst_student=inst_payment.where(status: "Paid").pluck(:instructor_student_id)
          @inst_award=@award_tests.pluck(:award_id)
          inst_payment = InstructorStudentAward.where("award_test_id IN (?) AND  award_id IN (?) AND instructor_student_id NOT IN (?) ",@award_tests.ids,@inst_award,inst_student).pluck(:award_test_id)
        end
        @award_tests=@award_tests.where("Id IN (?)",inst_payment)
      end
      if params[:status].present? && params[:status] != ""
        logger.info"---params[:status]---status-------------"
        inst_tests = InstructorStudentAward.where("award_test_id IN (?) AND status = ? ",@award_tests.ids,params[:status]).pluck(:award_test_id)
        @award_tests=@award_tests.where("Id IN (?)",inst_tests)
      end
  
    else
      start_date = Date.today
      @award_tests = AwardTest.where("test_date >= ?", start_date).order("test_date desc , test_time")
      @test_id = @award_tests.pluck(:id)
      award_id = @award_tests.pluck(:award_id)
      @award = Award.where("id IN (?)", award_id)
    end
    
    # @award=Award.where(id: @award_tests.pluck('award_id')).order('position')

    @all_award_id = InstructorStudentAward.where("award_progress IN (?) AND is_registered = false", ["Ready_for", "ready_for"]).pluck("award_id").uniq
    @all_student = InstructorStudentAward.where("award_progress IN (?) AND is_registered = false", ["Ready_for", "ready_for"]).pluck("instructor_student_id").uniq
    @all_student_id = []
    @all_student.each do |m|
      if !InstructorStudent.find(m).nil?
        if InstructorStudent.find(m).group_classes.count > 0
          @all_student_id  << m
        end
      end
    end
    @award=Award.where("id IN (?)", @all_award_id).order('position')

    if @award.present?
      @unregister=[]
      @inst_ids = []
      @award.each do |award|
        @inst_stdnt_ids=InstructorStudentAward.where('award_id IN (?)' , award.id).pluck(:instructor_student_id)
        @inst_id=InstructorStudent.where('id IN (?)', @all_student_id.uniq).pluck(:admin_user_id).uniq
        if @inst_id.count > 0
          @inst_id.each do |m|
            @inst_ids << m
          end
        end
        # @inst_name=AdminUser.where('id IN (?)',@inst_id) 
        @unregister_count = InstructorStudentAward.where('instructor_student_id IN (?) AND award_progress = ? AND is_registered = ? AND award_id IN (?)' , @all_student_id ,"ready_for","false",award.id)
        @unregister << @unregister_count.pluck(:instructor_student_id)
        @inst_name=AdminUser.where('id IN (?)',@inst_ids) 
      end
    end
    render layout: "setting_data"
  end

  def new
    @award_test = current_admin_user.award_tests.new
  end

  def create
    @award_test =  current_admin_user.award_tests.new(award_test_params)
    if @award_test.save
      respond_to do |format|
        format.html { redirect_to manage_award_tests_path}
      end
    end
  end

  def edit
    @award_test = AwardTest.find(params[:id])
    @instructor_student_award = @award_test.instructor_student_awards.where(:award_id => @award_test.award_id)
  end

  def update
    @award_test = AwardTest.find(params[:id])
    @award_test.update(award_test_params)
    respond_to do |format|
      format.html { redirect_to manage_award_tests_path}
    end
  end

  def show
    @award_test = AwardTest.find(params[:id])
    @instructor_student_award = @award_test.instructor_student_awards.where(:award_id => @award_test.award_id)
    # @instructor_student_award = InstructorStudentAward.where(:award_test_id => @award_test.id)
    render layout: "setting_data"
  end

  def destroy
    @award_test = AwardTest.find(params[:id])
    @award_test.destroy
    respond_to do |format|
       format.html {  redirect_to manage_award_tests_path }
    end
  end

  def remove_student
    @instructor_student_award = InstructorStudentAward.find(params[:id])
    @instructor_student_award.update(:award_progress => "ready_for", :award_test_id => nil, :status => nil, :is_registered => false)
    # respond_to do |format|
      # format.html {  redirect_to manage_award_tests_path }
      # format.js
    # end
  end

  def award_test_list
    @instructor_student_award = InstructorStudentAward.find(params[:id])
    @award_test_id = params[:test_id]
    @award_tests = AwardTest.where(award_id: @instructor_student_award.award_id).where('test_date >= (?) AND id NOT IN (?)',Time.now,@award_test_id).order("test_date desc , test_time")
  end

  def award_test_list_bulk
    @instructor_student_award = InstructorStudentAward.find_by(instructor_student_id: params[:student_list])
    @award_test_id = params[:id]
    @award_tests = AwardTest.where(award_id: params[:award_id]).where('test_date >= (?) AND id NOT IN (?)',Time.now,@award_test_id).order("test_date desc , test_time")
  end

  def transfer_student
    if params[:students_id].present?
      @instructor_student_award=InstructorStudentAward.where('award_id = ? AND instructor_student_id IN (?)' ,params[:award_id],params[:students_id].split(',')).update_all(:award_test_id=>params[:award_test_id])
      AwardTestPaymentNotification.where(award_test_id: params[:award_test_id_old],instructor_student_id: params[:students_id].split(',')).update_all(:award_test_id=>params[:award_test_id])
        logger.info"<---------------#{@instructor_student_award}------------------>"
    else
      @instructor_student_award = InstructorStudentAward.find(params[:id])
      @instructor_student_award.update(:award_test_id => params[:award_test_id])
      AwardTestPaymentNotification.where(award_test_id: params[:award_test_id_old],instructor_student_id:@instructor_student_award.instructor_student.id).update_all(:award_test_id=>params[:award_test_id])
    end
    redirect_to manage_award_test_path(params[:award_test_id_old])
  end

  def confirm_student
    @instructor_student_award = InstructorStudentAward.find(params[:id])
    @test_date = @instructor_student_award.award_test.test_date
    @instructor_student_award.update(:status => params[:value])
    @student_awrd_status = @instructor_student_award.award_progress
    # if params[:value] == "Pass"
    #   logger.info "<-------#{@instructor_student_award.inspect}-------->"
    #   # @instructor_student_award.update_attributes(:achieved_date => @test_date, :award_progress => "achieved")
    #   logger.info "<-------#{@instructor_student_award.inspect}-------->"
    # end
    if params[:value] == "Fail"
        if @student_awrd_status == "training_for"  
          # @instructor_student_award.update_attributes(:achieved_date => "", :award_progress => "training_for")    
        end
        if @student_awrd_status == "ready_for" || @student_awrd_status == "achieved" 
          # @instructor_student_award.update_attributes(:achieved_date => "", :award_progress => "ready_for")
        end
      #@instructor_student_award.update_attributes(:achieved_date => "", :award_progress => "ready_for")  
    end
    respond_to do |format|
      format.html {  redirect_to manage_award_test_path(@instructor_student_award.award_test_id) }
    end
  end


  def search_student
    @award_test = AwardTest.find(params[:award_test])
    @instructor_students = InstructorStudent.where('ic_number LIKE ? OR lower(student_name) LIKE ?', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").where(:is_deleted => false)
    logger.info "<------#{params[:search]}------------->"
    logger.info "<----#{InstructorStudent.where('ic_number LIKE ? OR lower(student_name) LIKE ?', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").where(:is_deleted => false)}----------->"
    logger.info "<---------#{@instructor_students.count}----->"
    respond_to do |format|
      format.js
    end
  end

  def add_student_award
    @award_test = AwardTest.find(params[:award_test])
    @student_id = params[:studdent_id]
    @instructor_student_award = InstructorStudentAward.find_by(:award_id => @award_test.award_id, :instructor_student_id => @student_id)

    if !@instructor_student_award.nil?
      @instructor_student_award = @instructor_student_award.update( :instructor_student_id => @student_id, 
                                                            :award_id => @award_test.award_id,
                                                            :award_test_id => @award_test.id,
                                                            :status => "Pending",
                                                            :is_registered => true,
                                                            :award_progress => "ready_for")
       redirect_to manage_award_test_path(@award_test.id), :notice => "Student was add for test successully"    
    else
      @instructor_student_award = InstructorStudentAward.new( :instructor_student_id => @student_id, 
                                                            :award_id => @award_test.award_id,
                                                            :award_test_id => @award_test.id,
                                                            :status => "Pending",
                                                            :is_registered => true,
                                                            :award_progress => "ready_for")
      if @instructor_student_award.save
        redirect_to manage_award_test_path(@award_test.id), :notice => "Student was add for test successully"  
      end
    end
  end

  def sort
    @award_tests = AwardTest.all
    params[:award_test].each_with_index do |id, index|
      @award_tests.where(:id => id).each do |p|
        p.update position: index+1
      end
    end
    render nothing: true
  end

  def sort_student
    @award_test = AwardTest.find(params[:id])
    @award_test_student = @award_test.instructor_student_awards.all
    params[:"award-test-student"].each_with_index do |id, index|
      @award_test_student.where(:id => id).each do |p|
        p.update position: index + 1
      end
    end
    render nothing: true
  end
  
  def bulck_confirm
    @award_test = AwardTest.find(params[:id])
    @student_list = params[:student_list].split(',')
    @student_list.each do |student_id|
      @student_award = InstructorStudentAward.where(:award_test => @award_test.id, :instructor_student_id => student_id.to_i)
      if @student_award.count > 0
        @student_award.update_all(:status => "Confirmed")
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def bulck_pass
    @award_test = AwardTest.find(params[:id])
    @student_list = params[:student_list].split(',')
    @student_list.each do |student_id|
      @student_award = InstructorStudentAward.where(:award_test => @award_test.id, :instructor_student_id => student_id.to_i)
      @test_date = @award_test.test_date
      if @student_award.count > 0
        @student_award.each do |student|
          # student.update_attributes(:achieved_date => @test_date, :award_progress => "achieved", :status => "Pass")
          student.update_attributes( :status => "Pass")
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def bulk_fail
    @award_test = AwardTest.find(params[:id])
    @student_list = params[:student_list].split(',')
    @student_list.each do |student_id|
      @student_award = InstructorStudentAward.where(:award_test => @award_test.id, :instructor_student_id => student_id.to_i)
      if @student_award.count > 0
        @student_award.update_all(:status => "Fail")
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def bulk_delete
    @award_test = AwardTest.find(params[:id])
    @student_list = params[:student_list].split(',')
    @student_list.each do |student_id|
      @student_award = InstructorStudentAward.where(:award_test => @award_test.id, :instructor_student_id => student_id.to_i).update_all(:award_progress => "ready_for", :award_test_id => nil, :status => nil, :is_registered => false, :achieved_date => nil)
    end
    respond_to do |format|
      format.js
    end
  end

  private
  
  def award_test_params
    params.require(:award_test).permit(:test_date,:test_fee,:test_time,:award_id,:venue_id,:assessor, :admin_user_id, :total_slot, :assesment_ref_no, :position,:cut_off_date)
  end
  def check_user_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      end
    else
      redirect_to manage_root_path
    end
  end
end  