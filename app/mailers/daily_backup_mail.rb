class DailyBackupMail < ActionMailer::Base
  default from: "enquiry@singaporeswimming.com"

  def student_info_to_instructor(instructor, group_classes, month_array)
    xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "instructor/instructor_profile/export", locals: {group_classes: group_classes, month_array: month_array}
    attachments["StudentDetails_#{Date.today}.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}
    mail(:to => instructor.email, :subject => "Backup mail : Student detail #{Date.today}")
  end
end
