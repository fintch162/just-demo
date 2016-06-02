class Instructor::GalleriesController < Instructor::BaseController
	before_action :check_user_permission, only: [ :new, :update, :edit, :destroy, :create ] 

	def index
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@galleries = Gallery.all
	end

	def new
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@gallery = Gallery.new
	end
	
	def create
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@gallery = Gallery.create(:instructor_student_id => @instructor_student.id )
		if @gallery.save
			redirect_to  instructor_instructor_student_path(@instructor_student.id)+"#gallery"
			#redirect_to  instructor_instructor_student_gallery_path(@instructor_student.id,@gallery.id)
		end
	end
	
	def show
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@gallery = @instructor_student.gallery.id
		@photos = @instructor_student.gallery.photos.paginate(page: params[:page], per_page: 8).order('created_at DESC')
	  #@videos = @instructor_student.gallery.videos.paginate(page: params[:page], per_page: 2).order('created_at DESC')
  end

	def edit
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@gallery = @instructor_student.gallery		
	end

	def update
		@instructor_student = InstructorStudent.find(params[:instructor_student_id])
		@gallery_id = @instructor_student.gallery.id
		@gallery = @instructor_student.gallery
		redirect_to  instructor_instructor_student_gallery_path(@instructor_student.id,@instructor_student.gallery.id)
	end
	
	private
	def gallery_params
    #params.require(:gallery).permit(:instructor_student_id, photos_attributes: [:id,:student_photo, :_destroy]) rescue {}
  	params.require(:gallery).permit!
  end

end