class EmbedRegistration < ActionMailer::Base
  default from: "enquiry@singaporeswimming.com"

  def registration_info(job)
  	@job = job
  	logger.info "<-----#{@job.inspect}------------>"
  	mail(:to => @job.lead_email, :subject => "Registration for swimming lessons")
  end

  def send_message_as_email(content, job)
    @job = job
    @content = content
    mail(:to => @job.lead_email, :subject => "Update on swimming lessons - Singapore Swimming Academy")
  end
end
