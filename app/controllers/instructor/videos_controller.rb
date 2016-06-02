class Instructor::VideosController < Instructor::BaseController
	before_action :check_user_permission, only: [ :new, :update, :edit, :destroy, :create ] 
  before_action :set_video, only: [:show, :edit, :destroy, :update]

  def index
  	@instructor_student = InstructorStudent.find(params[:instructor_student_id])
  	@gallery = Gallery.find(params[:gallery_id])
    @videos = Video.all
  end

  def new
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
   # logger.info("......1..#{@gallery.inspect}.....")
   # logger.info "<------123456----#{Video.new}---------------->"
    # exit
        # logger.info("......4....................#{@gallery.videos.inspect}")
        # exit
    @video = @gallery.videos.new
  end
  
  def create
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = Gallery.find(params[:gallery_id])
    @video = @gallery.videos.create(:gallery_id => @gallery.id, :instructor_student_id => @instructor_student.id, :video_file => params[:file])
    logger.info("......@video....................#{@video.inspect}")
    # if @video.save
    #   redirect_to @video, notice: 'Video was successfully created.'
    # else
    #   render :new
    # end 
    if @video.save
      respond_to do |format|
        format.json{ render :json => {:id => @video.id, :video_file => @video.video_file.url,:instructor_student_id => @video.instructor_student_id, :galary_id => @video.gallery_id} }
      end
    else
      render json: { error: @video.errors.full_messages.join(', ') }, status: :bad_request
    end
  end

  def update
    if @video.update(video_params)
      redirect_to @video, notice: 'Video was successfully updated.'
    else
      render :edit
    end
  end

  def show
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
    @video = video.find(params[:id])
  end

  def destroy
    # logger.info("......2....................#{params}")
    # exit
    @instructor_student = InstructorStudent.find(params[:instructor_student_id])
    @gallery = @instructor_student.gallery
    @video.destroy
    redirect_to  instructor_instructor_student_gallery_path(@instructor_student.id,@instructor_student.gallery.id)
  end

 private
  def set_video
      @video = Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:instructor_student_id,:gallery_id,:video_file) rescue {}
  end

end
