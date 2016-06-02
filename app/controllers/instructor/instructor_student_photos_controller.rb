class Instructor::InstructorStudentPhotosController < Instructor::BaseController
	before_action :check_user_permission
	def index
    @students = current_admin_user.instructor_students.includes(:group_classes,:gallery => :photos)
    @instructor_student_photos = current_admin_user.instructor_student_photos.includes(:photo_tags => :instructor_student)
	end

	def create
    @photo = current_admin_user.instructor_student_photos.create(:photo => params[:file])
    if @photo.save
      # @students = current_admin_user.instructor_students
      # @instructor_student_photos = current_admin_user.instructor_student_photos
      respond_to do |format|
        format.json{ render :json => {:id => @photo.id, :photo => @photo.photo.url(:small), :photo_original =>@photo.photo.url(:original) } }
      end
    else
      render json: { error: @photo.errors.full_messages.join(', ') }, status: :bad_request
    end
  end

  def update
    @photo = InstructorStudentPhoto.find(params[:id]) 
    @photo.update(instructor_student_photo_params)
    redirect_to instructor_instructor_student_photos_path
  end
  def add_tags
    inst_id = params[:instructor_id]
    photo_id = params[:photo_id]
    type = params[:type]
    @tags = PhotoTag.where(phototaggable_id: photo_id,phototaggable_type: type)
    if params[:student_ids].present?
      @tags = PhotoTag.where(phototaggable_id: photo_id,phototaggable_type: type).where('instructor_student_id NOT IN (?)',params[:student_ids])
      params[:student_ids].each do |student|
        if PhotoTag.find_by(instructor_student_id: student,phototaggable_id: photo_id,phototaggable_type: type).nil?
          PhotoTag.create(instructor_student_id: student,instructor_id: inst_id,phototaggable_id: photo_id,phototaggable_type: type)
        end
      end
    end
    @tags.destroy_all if @tags.count > 0
    @students = current_admin_user.instructor_students
    @instructor_student_photos = current_admin_user.instructor_student_photos
    respond_to :js
    # redirect_to instructor_instructor_student_photos_path
    # if params[:name] == 'student'
    #   @photo = Photo.find(params[:pk])
    #   @photo.update({"tag_list"=>params[:value].join(',')})
    # else
    #   @photo = InstructorStudentPhoto.find(params[:pk])
    #   @photo.update({"tag_list"=>params[:value].join(',')})
    # end
    # @students = current_admin_user.instructor_students
    # @instructor_student_photos = current_admin_user.instructor_student_photos
    # respond_to :js
  end
  def tagging_form
    # instructor_tagging_form_path
    @students = current_admin_user.instructor_students
    @p = InstructorStudentPhoto.find(params[:id])
    respond_to :js
  end

	def destroy
    if params[:is_id].present?
      @photo = Photo.find(params[:id])
    else
      @photo = InstructorStudentPhoto.find(params[:id])
    end
    # @photo.tag_list.remove(@photo.tag_list, :parse => true)
    # @photo.save
    @photo.destroy
    @students = current_admin_user.instructor_students
    @instructor_student_photos = current_admin_user.instructor_student_photos
    respond_to do |format|
      format.html {redirect_to instructor_instructor_student_photos_path}
      format.js
    end
  end

  private
    def instructor_student_photo_params
      params.require(:instructor_student_photo).permit(:instructor_id,:photo, :tag_list) 
    end
end