class Manage::MessageTemplatesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_message_template, only: [:show, :edit, :destroy]
  respond_to :html, :json
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Automation", :manage_message_templates_path
  before_action :set_template_example, :only => [ :index, :new, :edit ]
  before_action :find_message_template, :only => [ :index, :edit, :update ]
  def index
    @canned_response = CannedResponse.new
  end

  def set_template_example
    @jobs = Job.all
    @job = @jobs.first
    if @jobs.count != 0
      @venue = Venue.find(@jobs.first.venue_id).name if @jobs.first.venue_id.present?
      @class_type = ClassType.find(@jobs.first.class_type).title if@jobs.first.class_type.present?
      @class_level = Level.find(@jobs.first.class_level).title if@jobs.first.class_level.present?
      @age_group = AgeGroup.find(@jobs.first.age_group).title if @jobs.first.age_group.present?
    end
  end

  def show
  end

  def new
    @message_template = MessageTemplate.new
  end

  def edit
    @fee_type = FeeType.find(@job.fee_type_id).name if @job.fee_type_id.present?
    @students = @job.students if @job.students.present?
    render :layout => "setting_data"
  end

  def create
    @message_template = MessageTemplate.new(message_template_params)

    authorize(@message_template)
    @message_template.save
    @message_template.update_attributes(:job_status => params[:job_status] )
    redirect_to edit_manage_message_template_path(@message_template)
  end

  def update
    if params[:job_status] == "post"
      @message_template_post.update(message_template_params)
      @message_template_post.update_attributes(:job_status => params[:job_status] )
      # redirect_to edit_manage_message_template_path(@message_template_post)
      redirect_to manage_message_templates_path
    elsif params[:job_status] == "suggest"
      @message_template_suggest.update(message_template_params)
      @message_template_suggest.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
      # redirect_to edit_manage_message_template_path(@message_template_suggest)
    elsif params[:job_status] == "invoice"
      @message_template_invoice.update(message_template_params)
      @message_template_invoice.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
      # redirect_to edit_manage_message_template_path(@message_template_invoice)
    elsif params[:job_status] == "receipt"
      @message_template_receipt.update(message_template_params)
      @message_template_receipt.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
      # redirect_to edit_manage_message_template_path(@message_template_receipt)
    elsif params[:job_status] == "invoice_note"
      @message_template_invoice_note.update(message_template_params)
      @message_template_invoice_note.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
    elsif params[:job_status] == "payment_advise"
      @message_template_payment_advise.update(message_template_params)
      @message_template_payment_advise.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
    elsif params[:job_status] == "invoice_pa"
      @message_template_invoice_pa.update(message_template_params)
      @message_template_invoice_pa.update_attributes(:job_status => params[:job_status] )
      redirect_to manage_message_templates_path
    end
  end

  def render_edit_form
    respond_to do |format|
      format.html do
        if @message_template.valid?
          redirect_to edit_manage_message_template_path(@message_template)
        else
          render "edit"
        end
      end
      format.json do
        if @message_template.valid?
          render json: { status: 202 }
        else
          render json: {}, status:  422
        end
      end
    end    
  end

  def webhook
    es = FreshBooks::Client.new('mike342.freshbooks.com', 'fc1851316196e497b3163aaed0c29e73')
    # es= FreshBooks::Client.new('swimming.freshbooks.com', '32e66af86dfd8f7202fbea4347cece5f')  
  end


  def destroy
    @message_template.destroy
    authorize(@message_template)
    respond_with :manage, @message_template
  end

  def get_template_on_generate_sms
    #  Update job attributes
    venue = params[:venue_val]
    class_level = params[:class_val]
    age_group = params[:age_val]
    class_type = params[:classtype_val]
    day_of_week_val = params[:day_of_week_val]
    start_date_val = params[:start_date_val]
    fee_type_id = params[:fee_structure_val]
    completed_by = params[:completed_by_val]
    lesson_count = params[:lesson_count_val]
    preferred_time = params[:preferred_time_val]
    fee_total = params[:fee_total_val]
    referral = params[:referral_val]
    class_time_val = params[:class_time_val]
    par_pax_val = params[:par_pax_val]
    show_names = params[:show_names_val]
    free_goggles = params[:free_goggles_val]
    lady_instructor = params[:lady_instructor_val]
    instructor = params[:instructor]
    job_status = params[:job_status]
    job_coordinator_notes = params[:job_coordinator_notes]
    other_venue = params[:other_venue]
    request_full_payment = params[:request_full_payment]
    duration = params[:duration]

    @job = Job.find(params[:current_job])
    @job.update_attributes(:duration => duration,:request_full_payment => request_full_payment, :other_venue => other_venue, :par_pax => par_pax_val, :instructor_id => instructor, :venue_id => venue, :job_status => job_status, :class_type => class_type, :age_group => age_group, :class_level => class_level, :preferred_time => preferred_time, :day_of_week => day_of_week_val, :class_time => class_time_val, :start_date => start_date_val,:fee_type_id => fee_type_id, :completed_by => completed_by, :lesson_count => lesson_count, :fee_total => fee_total, :referral => referral,:coordinator_notes => job_coordinator_notes, :show_names => show_names, :free_goggles => free_goggles, :lady_instructor => lady_instructor)

    @message_template = MessageTemplate.find_by_job_status(params[:job_status].downcase) if !params[:job_status].blank?
    
    @instructor_template_body = ""
    @customer_template_body = ""


    if @message_template.has_instructor?
      @instructor_template_body = @message_template.instructor_template_body
    end
    if @message_template.has_customer?
      @customer_template_body = @message_template.customer_template_body
    end
    if @message_template
      render :text => @customer_template_body + "*^*" + @instructor_template_body
    else
      render :text => '0'
    end
  end

  def get_invoice_note
    if params[:with_view_pa_link]
      @message_template = MessageTemplate.find_by_job_status(params[:with_view_pa_link].downcase) if !params[:with_view_pa_link].blank?
      @message_template = @message_template.invoice_pa_body
    else
      message_template = MessageTemplate.find_by_job_status("invoice_note")
      view_pa = MessageTemplate.find_by_job_status("payment_advise")
      if message_template
        @message_template = message_template.invoice_note_body
      end
      if view_pa
        @message_template = view_pa.payment_advise_body
      end
      if message_template && view_pa
        @message_template = message_template.invoice_note_body + "---%---" + view_pa.payment_advise_body
      end
    end
      if @message_template
        render :text => @message_template
      else
        render :text => '0'
      end
  end

  private
    def find_message_template
      @message_template_post = MessageTemplate.find_by_job_status("post")
      @message_template_suggest = MessageTemplate.find_by_job_status("suggest")
      @message_template_invoice = MessageTemplate.find_by_job_status("invoice")
      @message_template_receipt = MessageTemplate.find_by_job_status("receipt")
      @message_template_invoice_note = MessageTemplate.find_by_job_status("invoice_note")
      @message_template_payment_advise = MessageTemplate.find_by_job_status("payment_advise")
      @message_template_invoice_pa = MessageTemplate.find_by_job_status("invoice_pa")
    end
    def set_message_template
      @message_template = MessageTemplate.find(params[:id])
      authorize(@message_template)
    end

    def message_template_params
      params.require(:message_template).permit(:job_status, :has_instructor, :has_customer, :customer_template_body, :instructor_template_body, :invoice_note_body, :payment_advise_body, :invoice_pa_body, :app_posting_template,:receipt_note,:app_receipt_template) rescue {}
    end

    
end