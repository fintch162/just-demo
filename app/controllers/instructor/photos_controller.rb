class Instructor::PhotosController < Instructor::BaseController
  before_action :check_user_permission, only: [ :new, :update, :edit ] 

  def index
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = Gallery.find(params[:gallery_id])
    @photos = Photo.all
  end

  def new
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
    @photo = @gallery.photos.new
  end
  
  def create
    is_image =['image/jpeg' ,'image/jpg', 'image/png', 'image/gif', 'image/tiff','image/bmp']
    is_video =['video/mp4' ,'video/mv4','video/quicktime', 'video/webm', 'video/mov', 'video/flv','video/wmv','video/avi','video/mpeg2']
    @a = params[:file].content_type
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
      @gallery = Gallery.find(params[:gallery_id])
    if is_image.include?(@a)
      @photo = @gallery.photos.create(:gallery_id => @gallery.id, :instructor_student_id => @instructor_student.id, :student_photo => params[:file])
      if @photo.save
        @photo.photo_tags.create(instructor_student_id: @instructor_student.id)
        respond_to do |format|
          format.json{ render :json => {:id => @photo.id, :student_photo => @photo.student_photo.url(:small), :student_photo_original =>@photo.student_photo.url(:original) ,:instructor_student_id => @photo.instructor_student_id, :galary_id => @photo.gallery_id} }
        end
      else
        render json: { error: @photo.errors.full_messages.join(', ') }, status: :bad_request
      end
    end
    # if is_video.include?(@a)
    #   @video = @gallery.videos.create(:gallery_id => @gallery.id, :instructor_student_id => @instructor_student.id, :video_file => params[:file]) 
    #   if @video.save
    #     respond_to do |format|
    #       format.json{ render :json => {:id => @video.id, :video_file => @video.video_file.url,:instructor_student_id => @video.instructor_student_id, :galary_id => @video.gallery_id} }
    #     end
    #   else
    #     render json: { error: @video.errors.full_messages.join(', ') }, status: :bad_request
    #   end
    # end
  end

  def show
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
    @photo = Photo.find(params[:id])
  end

  def destroy
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
    @photo = Photo.find(params[:id])
    @photo.destroy
    #redirect_to  instructor_instructor_student_gallery_path(@instructor_student.id,@instructor_student.gallery.id)
    if params[:from_public].present?
      redirect_to student_public_gallery_path(@instructor_student.secret_token)
    else
      redirect_to  instructor_instructor_student_path(@instructor_student.id)+"#gallery"
    end
  end

  private
  
  def photo_params
    params.require(:photo).permit(:instructor_student_id,:gallery_id,:student_photo) rescue {}
    #params.require(:photo).permit!
  end

end