class Instructor::GroupClassesController < Instructor::BaseController
  def add_to_group_class
    @student = Student.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def add_student_to_gp
    @instructor_student = current_admin_user.instructor_students.new(:gender => params[:student_gender], :student_name => params[:student_name], :group_class_ids => params[:group_class_id])
    @instructor_student.student_contacts.new(:contact => params[:lead_contact], :primary_contact => true)
    @instructor_student.save
    redirect_to instructor_referrals_path
  end
  
  def destroy
    @group_class = GroupClass.find(params[:id])
    @group_class.update is_deleted: true
    redirect_to instructor_group_classes_index_path
  end

  def update_slot_vacancy
    @group_class = GroupClass.find(params[:id])
    @group_class.update(group_class_params)
    render json: @group_class
  end
  private
  def group_class_params
    params.require(:group_class).permit(:slot_vacancy, :slot_maximum, :day, :time, :fee_type_id, :duration, :level_id, :instructor_id, :venue_id, :age_group_id, :class_type_id, :lesson_count, :remarks, :fee, :admin_user_id) rescue {}
  end
end