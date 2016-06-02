class InstructorPubliclyVisibleController < ApplicationController
  layout "instructor_public_page"
  def publicly_visible_inst_profile
    name = params[:name].tr("-", " ")
    @instructor = Instructor.find_inst_by_name(name)
    if @instructor.blank?
      render "public/routing_err.html"
    else
      @instructor_gp = @instructor.group_classes.order('day asc,time asc')
      # adult_age = AgeGroup.find_by_title("Adult").id
      # kid_age = AgeGroup.find_by_title("Kids").id
      # @instructor_gp_adult = @instructor.group_classes.order('day asc,time asc').where(age_group_id: adult_age)
      # @instructor_gp_kid = @instructor.group_classes.order('day asc,time asc').where(age_group_id: kid_age)
    end
  end
end
