module WelcomeHelper
	puts"---------in helper-----------------"

	def convert_job_template(message_template,job,user)
		if message_template
      feeTotal = job.fee_total ? job.fee_total : 0
      referral = job.referral ? job.referral : 0
      list_students = ''
      job.students.each do |stu|
      	# list_students += stu.name.present? ? stu.name : '' + '-' + stu.age.present? ? stu.age.to_s : '' + 'yrs ' + '(' + stu.sex.present? ? stu.sex : '' + ')' + '<br>'
        list_students += stu.name.present? ? stu.name : ''
        list_students += stu.name.present? ? '-' : ''
        list_students += stu.age.present? ? stu.age.to_s : ''
        list_students += stu.age.present? ? 'yrs ' : ''
        list_students += stu.sex.present? ? '(' + stu.sex + ')' : ''
        list_students += (stu.name.present? || stu.age.present? || stu.sex.present?) ? '<br>' : ''
    	end
      @day = ''
      Job::DAY_ARRAY.each_with_index do |day,i|
        if (job.day_of_week.to_i == i)
          @day = day
        end
      end
      @venue_name = ''
      if job.venue_id?
        if Venue.find(job.venue_id).name == "Condo"
          @venue_name = "Condo: " + job.other_venue
        else
          @venue_name = Venue.find(job.venue_id).name
        end 
      end
        # @venue = job.venue_id ? Venue.find(job.venue_id).name : ''
      @class_type = (job.class_type.nil? || job.class_type == "") ?  '' : ClassType.find(job.class_type.to_i).title
      unless user.nil?
        @job_application = job.instructor_job_applications ? job.instructor_job_applications.find_by(:instructor_id => user.id,job_id:job.id) : job.instructor_job_applications
      end
      @job_Student = job.students ? job.students.count.to_s : '0'

			message_template = message_template
          .gsub('< id >',job.id.to_s)
          .gsub('< venue_name >', @venue_name)
          .gsub('< class_level >',(job.class_level.nil? || job.class_level == "") ? '' : Level.find_by(id: job.class_level.to_i).title)
          .gsub('< age_group >',( job.age_group.nil? || job.age_group == "") ? '' : AgeGroup.find(job.age_group.to_i).title)
          .gsub('< class_type >', @class_type)
          .gsub('< pa_link >','not_pa')
          .gsub('< start_date >',job.start_date ? job.start_date.strftime('%e %B %Y') : '')
          .gsub('< completed_by >',job.completed_by ? job.completed_by.to_s : '')
          .gsub('< fee_type >',job.fee_type_id ? job.fee_type.name : '')
          .gsub('< student_count >',@job_Student)
          .gsub('< list_students >',list_students)
          .gsub('< preferred_time >',job.preferred_time ? job.preferred_time.gsub("\n", "<br/>") : '')
          .gsub('< class_time >',job.class_time ? job.class_time.strftime("%l:%M%P") : '')
          .gsub('< day_of_week >',job.day_of_week ? @day : '')
          .gsub('< duration >',job.duration ? job.duration : '')
          .gsub('< per_pax >',job.par_pax ? job.par_pax.to_s : '')
          .gsub('< fee_total >',feeTotal.to_s)
          .gsub('< referral >',referral.to_s)
          .gsub('< fee_remainder >',(feeTotal - referral).to_s)
          .gsub('< lead_name >',job.lead_name ? job.lead_name : '')
          .gsub('< lead_contact >',job.lead_contact ? job.lead_contact : '')
          .gsub('< instructor_name >',job.instructor_id ? job.instructor.short_name : '')
          .gsub('< instructor_contact >',job.instructor_contact ? job.instructor_contact : job.instructor_id ? job.instructor.mobile : '')
          .gsub('< lesson_count >',job.lesson_count ? job.lesson_count.to_s : '')
          .gsub('< show_names >',job.show_names ? job.show_names.to_s : 'false')
          .gsub('< lady_instructor >',job.lady_instructor ? job.lady_instructor.to_s : '')
          .gsub('< free_goggles >',job.free_goggles ? job.free_goggles.to_s : 'false')
          .gsub('< full_payment >',job.request_full_payment ? job.request_full_payment.to_s : '')
        logger.info "<-------------------#{message_template}------------>"
      template_decoder(message_template)
    end
	end


 	def template_decoder(message_template)
    str = message_template
    start = false
    extrastr = ""
    newstring = ""
    conditions = []
    str = solidReplace(str, "if(", "^(");
    str = solidReplace(str, "else{", "^^{");
    str = solidReplace(str, "&quot;", "");
    str = solidReplace(str, "&lt;", "<");
    str = solidReplace(str, "&gt;", ">");
    str = removenl(str);
    
    # str = br2nl(str);
    (0...str.length).each do |t|
      char = str[t]
      if (char == "(") 
        start = true;
      end
      if (start == true) 
        newstring += char;
      end
      if (char == ")")
        start = false;
        unless newstring.nil? && newstring != ' '
          if isCondition(newstring)
            conditions << newstring
          end
        end
        newstring = ""
      end
    end
    (0...conditions.length).each do |t|
      n = conditions[t]
      r = getRes(n).to_s
      str = solidReplace(str, n, r)    
    end
    
    # while str.rindex("^^{").present? do
    # 	i = str[0,str.rindex("^^{")]
    #   if(i.rindex("^true{") > i.rindex("^false{"))
    #     str = i + "^false{" + str[(i.length+3)..-1]
    #   else
    #     str = i + "^true{" + str[(i.length+3)..-1]
    #   end
    # end
    (0...50).each do |t|
      if str.rindex("^^{").present?
        i = str[0,str.rindex("^^{")]
        if(i.rindex("^true{") > i.rindex("^false{"))
          str = i + "^false{" + str[(i.length+3)..-1]
        else
          str = i + "^true{" + str[(i.length+3)..-1]
        end
    	else
    		break
    	end
  	end
    s = ""
    o = false
    u = 0
    str = solidReplace(str, "^false", "`")
    (0...str.length).each do |t|
      char = str[t]
      if char.include?("{")
        if (o == true)
          u += 1
          s += "`"
        else
          s += "{"
        end
      elsif char.include?("}")
        if (o == true)
          u -= 1
          s += "`"
        else
          s += "}"
        end
        if (u <= 0)
          o = false
        end
      elsif char.include?("`")
        s += "`"
        o = true
      else
        if (o == true)
          s += "`"
        else
          s += char
        end
      end
    end
    str = solidReplace(s, "`", "");
    nstr1 = solidReplace(str, "^true{", "");
    nstr1 = solidReplace(nstr1, "}", "");
    return nstr1
  end 

  def solidReplace(e, t, n)
    if(e)
      r = e.to_s.split(t);
      return r.join(n)
    else
      return e
    end
  end

  def removenl(e)
    if(e)
      return e.gsub(/(\r\n|\n|\r)/, "")
    else
      return e
    end
  end

  def isCondition(e)
    t = ["==", "!=", ">", "<", ">=", "<="]
    (0...t.length).each do |n|
      if e.include?(t[n])
        return true
      end
    end
    return false
  end

  def getRes(e)
    t = ["==", "!=", ">", "<", ">=", "<="]
    n = []
    e = e[1, e.length - 2]
    (0..t.length).each do |r|
      if(e.include?(t[r]))
        n = e.split(t[r])
        return isMatched(n[0], n[1], t[r])
      end
    end
    return "(" + e + ")"
  end

  def isMatched(e,t,n)
    e = e.strip
    t = t.strip
    e = e.downcase
    t = t.downcase
    if (n == "==") 
    	if (e == t)
      	return true
      end
    end
    if (n == "!=") 
      if (e != t) 
        return true
      end
    end
    if (n == ">")
    	if (e > t)
      	return true
      end
    end
    if (n == "<") 
    	if (e < t)
      	return true
      end
    end
    if (n == "<=") 
    	if (e <= t)
     		return true
     	end
    end
    if (n == ">=") 
    	if (e >= t)
     		return true
     	end
    end
    return false
  end

end
