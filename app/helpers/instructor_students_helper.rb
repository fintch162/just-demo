module InstructorStudentsHelper
	def student_training_award_list(student)
		training_status = ["training_for", "Training"]
    pass_status = ["pass", "Pass", 'Pending', 'pending', 'Confirmed', 'confirmed' ]
    @training_for_award_ids = student.instructor_student_awards.where("award_progress IN (?) AND status NOT IN (?)", training_status, pass_status).pluck("award_id") 
    @training_for_award_ids += student.instructor_student_awards.where("award_progress IN (?) AND status IS ?", training_status, nil).pluck("award_id")
    @award_list = ""
    @awards = Award.where(id: @training_for_award_ids)
    @awards.each do |award|
      if !award.short_name.nil? && !award.short_name != "" 
        @awards.last != award ? @award_list += award.short_name + "," : @award_list += award.short_name
      else 
        @awards.last != award ? @award_list += award.name + "," : @award_list += award.name
      end
    end
	end

  def format_phon_number()
    if @response['to_number'].include?("+")
      if @response['to_number'].include?("^")
        @client_number = @response['to_number'][4..-1]
      else
        @client_number = @response['to_number'][3..-1]
      end
    else
      @client_number = @response['to_number'].gsub('^', '')
    end
    if @response['from_number'].include?("+")
      if @response['from_number'].include?("^")
        @telerivet_number = @response['from_number'][4..-1]
      else
        @telerivet_number = @response['from_number'][3..-1]
      end
    else
      if @response['from_number'].include?("^")
        @telerivet_number = @response['from_number'].gsub('^', '')
      else
        @telerivet_number = @response['from_number']
      end
    end
  end

  def day_in_words(date) # only date
    diff = (Date.today - date).to_i # Difference in days
    if diff < 0
      date.to_s
    elsif diff < 1
      "Today"
    elsif diff < 2
      "Yesterday"
    elsif diff.between?(2,6) # 3 to 6 days
      pluralize(diff, "day") + " ago"
    elsif (diff).between?(7,30) # 1 month weeks
      weeks = (diff+1)/7
      return pluralize(weeks, "week") + " ago"
    elsif (diff).between?(31,365)
      time_ago_in_words(date).gsub('about','') + ' ago'
    elsif diff.between?(366,730) # up to 1 year
      "1 year ago"
    else # after 1 year
      "Very long ago"
    end
  end
end
