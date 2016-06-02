class Instructor::GroupsController < Instructor::BaseController
  before_action :check_user_permission, only: [ :new, :update, :edit, :destroy, :create ] 
  def new
    @group = Group.new
  end
  def create
    
    @group = Group.new(group_params)
    @groups = Group.where(:group_class_id => @group.group_class_id)
    @group_class = GroupClass.find(@group.group_class_id)
    if @group.save
      respond_to do |format|
        format.js
      end
    else
    end
  end
  def sort
    logger.info "<-----#{params}------->"
    fromId = params[:fromId]
    if params[:fromList].present?
      fromList = params[:fromList]
    end
    toId = params[:toId]
    toList = params[:toList]
    logger.info "<-------#{toList}-------->"
    
    if fromId == toId
      if toId != "Default"
        logger.info "<-------#{"inif"}-------->"
        @group = Group.find(fromId)
        fromList.each_with_index do |list, index|
          @student = @group.instructor_students.find(list)
          @student.update(:position => (index + 1))
        end
      else
         logger.info "<-------#{"inelse"}-------->"
         fromList.each_with_index do |list, index|
          @student =InstructorStudent.find(list)
          @student.update(:position => (index + 1))
        end
      end
    else
      if params[:fromList].present?
        if fromId != "Default"
          @from_group = Group.find(fromId)
          fromList.each_with_index do |list, index|
            @student = @from_group.instructor_students.find(list)
            @student.update(:position => (index + 1))
          end
        end
      end
      if toId != "Default"
        @to_group = Group.find(toId)
        toList.each_with_index do |list, index|
          @student = InstructorStudent.find(list)
          @student.update(:position => (index + 1), :group_id => @to_group.id)
        end
      else
        toList.each_with_index do |list, index|
          @student = InstructorStudent.find(list)
          @student.update(:position => (index + 1), :group_id => nil)
        end
      end
      render text: "done"
    end
  end

  def update
    @group = Group.find(params[:id])
    
     respond_to do |format|
      if @group.update(:group_name => params[:group][:group_name])
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { respond_with_bip(@user) }
      end
    end
  end

  private
  def group_params
    params.require(:group).permit(:group_name, :group_class_id) rescue {}
  end

end