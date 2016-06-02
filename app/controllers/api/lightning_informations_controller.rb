module Api
  class LightningInformationsController < ApplicationController
    require 'mechanize'
    require 'nokogiri'
    require 'open-uri'
    def lightning_information
      url = 'http://www.weather.gov.sg/srv/lightning/lightning_alert_ssc.html'

      doc = Nokogiri::HTML(open(url, :http_basic_authentication => ['sscops' ,'sscops123']))
      rows = doc.css('tr')
      if rows.length > 0 
          location,risk,time = nil
          rows[3..-1].each do |row|
            cells = row.css('td')
            location,risk,time = cells[0..2].map{|c| c.text}
            if location.include?("Swimming Complex")
              @lightning_risk = LightningRisk.find_by_location(location)
              if !@lightning_risk.blank?
                @lightning_risk.update_attributes(:risk => risk , :time => time)
              else
                @lightning_risk = LightningRisk.create(:location => location, :risk => risk, :time => time)
              end  
            end  
          end 
      end      
      @l = LightningRisk.all
      render json: @l
    end
    

    def student_public_link_api
     puts"<----------------#{params}------------------------->"
      @instructor_student=InstructorStudent.find_by_secret_token(params[:secret_token])
      puts"<----------------#{@instructor_student.inspect}------------------------->"
      if @instructor_student.gallery.nil?
        @gallery = Gallery.create(instructor_student_id: @instructor_student.id) 
      else
        @gallery = @instructor_student.gallery
      end
      # @day_array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
      # award = params[:isAppliedFor]
      # award_test = params[:awardTest]
      @instructor_student_award = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for", :is_registered => false)
      # status = [ "Confirmed","pending", "Pending","confirmed", "fail", "Fail", "Pass", "pass", nil ]
      not_pass = [ "Confirmed","pending", "Pending","confirmed", "fail", "Fail"]
      @student_award_registered = InstructorStudentAward.where(:instructor_student_id => @instructor_student.id, :award_progress => "ready_for", :is_registered => true).where.not(:status => "Pass")
      # items = ["training_for", "ready_for"]
      @ready_award = @instructor_student.instructor_student_awards.where(:award_progress => "ready_for").where(:status => nil)
      @ready_award = @ready_award + @instructor_student.instructor_student_awards.where(:award_progress => "ready_for").where("status IN (?)", not_pass)

      @trainning_award = @instructor_student.instructor_student_awards.where(:award_progress => "training_for").where.not(:status => "Pass")
      @trainning_award += @instructor_student.instructor_student_awards.where(:award_progress => "training_for").where(:status => nil)

      @achieved_award = @instructor_student.instructor_student_awards.where("status IN (?)", ["pass", "Pass"])
      @achieved_award = @achieved_award + @instructor_student.instructor_student_awards.where(:award_progress => "achieved")

      @url=@instructor_student.profile_picture.url
      @photo=[]
      @instructor_student.photos.each do |stu_pic|
        @photo << stu_pic.student_photo.url
      end

      @award_image=[]
      c=@instructor_student.instructor_student_awards.pluck(:award_id)
      Award.where("Id IN (?)",c).each do |award|
        @award_image << {id: award.id, image_url: award.image.url ,name: award.name}
      end

      @student_award=[]
      @instructor_student.instructor_student_awards.each do |test|
        @student_award << test.award_test 
      end
      @venue=Venue.all
      @feature=@instructor_student.admin_user.instructor_features
      
      @fee_payment_info=[]
      @instructor_student.fees.each do |fee_payment|
        @fee_payment_info << {fee_payment_notification: fee_payment.fee_payment_notifications ,is_paid: fee_payment.is_paid}
      end
      # render json: {student_award_registered: @student_award_registered,ready_award: @ready_award,trainning_award: @trainning_award,achieved_award: @achieved_award,url: @url,student_gallery:@photo,instructor_student: @instructor_student.to_json(:include =>[:instructor_student_awards,:instructor_student_group_classes,:group_classes,:awards,:gallery,:award_test_payment_notifications,:student_contacts,:photo_tags,:admin_user,:fees =>{:include => [:fee_payment_notification]}])}

      render json: {student_award_registered: @student_award_registered,ready_award: @ready_award,trainning_award: @trainning_award,achieved_award: @achieved_award,instructor_student: @instructor_student.to_json(:include =>[:instructor_student_awards,:instructor_student_group_classes,:group_classes,:gallery,:award_test_payment_notifications,:student_contacts,:fees,:admin_user]),url: @url,student_gallery:@photo, award_image: @award_image, student_award: @student_award,venue: @venue, feature: @feature, fee_payment: @fee_payment_info}
    end

  end
end