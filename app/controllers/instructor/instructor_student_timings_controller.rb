class Instructor::InstructorStudentTimingsController < Instructor::BaseController
	before_action :check_user_permission
	
	def create
		logger.info"<-=-------------------#{params}----------------------------->"
		params[:instructor_student_timing][:time] = "00:"+params[:instructor_student_timing][:time]
		logger.info"<-=-------------------#{params[:instructor_student_timing][:time]}----------------------------->"
		@instructor_student_timing=InstructorStudentTiming.create(instructor_student_timing_params)
	end

	def update
		logger.info"<-=-------------------#{params}----------------------------->"
		params[:instructor_student_timing][:time] = "00:"+params[:instructor_student_timing][:time]
		@instructor_student_timing=InstructorStudentTiming.find(params[:id]).update_attributes(instructor_student_timing_params)
		logger.info"<------------------#{@instructor_student_timing}----------------------->"
		@instructor_student_timing=InstructorStudentTiming.find(params[:id])
	end

	def destroy
		@instructor_student_timing=InstructorStudentTiming.find(params[:id])
		@instructor_student_timing.destroy
		@instructor_student_timing=InstructorStudentTiming.where(instructor_student_id: params[:instructor_student] , timing_id: params[:time])
		@time_id= params[:time]
		@student_id=params[:instructor_student]
		@inst_timing=@instructor_student_timing.order('date DESC').order('updated_at DESC').limit(1).first 
	end

	private
	def instructor_student_timing_params
    	params.require(:instructor_student_timing).permit(:instructor_student_id, :timing_id, :time, :date)
  	end
end