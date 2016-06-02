class Instructor::StudentIdentitiesController < Instructor::BaseController
  def identity_upload
    @instructor_student = InstructorStudent.find(params[:id])
    file = params[:qqfile].is_a?(ActionDispatch::Http::UploadedFile) ? params[:qqfile] : params[:file]
    @student_identity = StudentIdentity.create(:instructor_student_id => @instructor_student.id)
    @student_identity.identity_doc = file
    @student_identity.save
    if admin_user_signed_in? 
      redirect_to instructor_instructor_student_path(@instructor_student)
    else
      render json: @instructor_student_l 
    end
  end

  def destroy
    @student_identity = StudentIdentity.find(params[:id])
    @instructor_student = @student_identity.instructor_student_id
    if @student_identity.present?
      @student_identity.destroy
      if admin_user_signed_in? 
        redirect_to instructor_instructor_student_path(@instructor_student)
      end
    end
  end
 
end 