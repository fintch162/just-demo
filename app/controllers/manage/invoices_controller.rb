class Manage::InvoicesController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  respond_to :js , only: [:get_freshbook_invoice]
  add_breadcrumb "Home", :manage_root_path
  before_action :load_api_setting
  before_action :check_user_permission, only: [ :index, :create, :get_freshbook_invoice, :destroy, :show, :freshbook_invoice ]

  def create
    @client = ''
    @m = []
    @job = Job.find(params[:id])
    begin
      timeout(100) do
        freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
        logger.info "||......... #{freshbookconnection} .........||"
        if !@job.lead_email.blank?
          client_list = freshbookconnection.client.list

          # logger.info "||......... #{client_list} .........||"
          # logger.info "||......... #{client_list["clients"]["total"]} .........||"
          # logger.info "||......... #{client_list["clients"]["total"]["email"]} .........||"

          if client_list["error"]
            @m << client_list["error"]
            @m << client_list["code"]
            render :text => @m, status: 422
          else
            if client_list["clients"]["total"].to_i > 0
              if client_list["clients"]["total"].to_i ==  1
                if client_list["clients"]["client"]['email'] == @job.lead_email
                  @client = client
                end
              else
                client_list.first[1]['client'].each do |client|
                  if client['email'] == @job.lead_email
                    @client = client
                    logger.info "||......... #{@client} .........||"
                  end
                end
              end
            end
            logger.info "|---------- #{params[:title_invoice]} ----------|"
            if @client.blank?
              @client = freshbookconnection.client.create(:client => {
                                                                      :first_name  => @job.lead_name,
                                                                      :organization => @job.lead_name,
                                                                      :email => @job.lead_email,
                                                                      :password => "password",
                                                                      :contacts => [{ :contact => {
                                                                      :email => @job.lead_email
                                                                      }}]
                                                        })
            end
            logger.info "||......... #{@client} .........||"

            if params[:free_starter_kit].blank?
              @client_invoice = freshbookconnection.invoice.create(:invoice => { :client_id => @client['client_id'], :po_number => @job.id, :notes => params[:invoice_info_body],
                                      :lines => [{ :line => {
                                         :name         => params[:title_invoice],
                                         :description  => params[:description_invoice],
                                         :unit_cost    => params[:unit_cost],
                                         :quantity     => params[:qty]
                                       }}]
              })
            else
              @client_invoice = freshbookconnection.invoice.create(:invoice => { :client_id => @client['client_id'], :po_number => @job.id, :notes => params[:invoice_info_body],
                                      :lines => [{ :line => {
                                         :name         => params[:title_invoice],
                                         :description  => params[:description_invoice],
                                         :unit_cost    => params[:unit_cost],
                                         :quantity     => params[:qty]
                                       }}, { :line => {
                                            :name         => "Free kit",
                                            :description  => params[:free_starter_kit],
                                            :unit_cost    => 0,
                                            :quantity     => params[:qty]
                                          }}]
              })
            end
            if !@client_invoice['inovice_id']
              @freshbook_id = @client_invoice.first[1]
              @job.update_attributes(:job_status => "Invoice")
              freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
              @invoice_number = freshbookconnection.invoice.get :invoice_id => @freshbook_id
              if @job.invoices.count > 0
                @inovice = @job.invoices.last.update_attributes(  
                                          :freshbooks_invoice_id => @freshbook_id, :invoice_number => @invoice_number.first[1]['number'],
                                          :job_id => @job.id, :invoice_time => (Time.zone.now+1440.minutes),:last_sync_inv_id => @invoice_number.first[1]['number'],
                                          :payment_advise => params[:view_pa]
                                        )
                @invoice = @job.invoices.last
              else
              @invoice = Invoice.create(  
                                          :freshbooks_invoice_id => @freshbook_id, :invoice_number => @invoice_number.first[1]['number'],
                                          :job_id => @job.id, :invoice_time => (Time.zone.now+1440.minutes),:last_sync_inv_id => @invoice_number.first[1]['number'],
                                          :payment_advise => params[:view_pa]
                                        )
              end
              time = @invoice.invoice_time - Time.zone.now
              @m << @invoice.id
              @m << @client_invoice.first[1]
              @m << @invoice.invoice_number
              @m << @invoice.u_sec_number
              @m << @invoice_number.first[1]['amount']
              @m << time
              render :json => @m

            else
              render :text => '0'
            end
          end
        else
          render :text => 'Email Cant be blank', status: 422
        end
      end
    rescue Timeout::Error, SocketError => e
      render :text => e, status: 503
    end
    logger.info"--------invoice--------------#{@invoice.inspect}----------------------------"
    
  end
  
  def reset_invoice_time_popup
    @invoice = Invoice.find(params[:id])
    respond_to :js
  end

  def reset_invoice_time
    @invoice = Invoice.find(params[:id])
    logger.info "<--------#{@invoice.inspect}--------#{Time.zone.now + params[:invoice_time].to_i.hours}-------->"
    time_in = Time.zone.now + params[:invoice_time].to_i.hours
    @invoice.update_attributes(invoice_time: time_in)
    # @invoice_time = Time.zone.now + params[:invoice_time].to_i.hours
    # logger.info "<--------#{@invoice.inspect}---------------->"
    # exit
    redirect_to manage_job_path(@invoice.job.id)
  end

  def clear_invoice_time
    @invoice = Invoice.find(params[:id])
    @invoice.update_attributes(invoice_time: '')
    logger.info "<--------#{@invoice.inspect}---------------->"
    redirect_to :back
  end

  def update_invoice
    @invoice = Invoice.find(params[:invoice_id])
    @job = Job.find(params[:job])
    timeout(100) do
      freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      if !@job.lead_email.blank?
        client_list = freshbookconnection.client.list
        if client_list["error"]
          @m << client_list["error"]
          @m << client_list["code"]
          render :text => @m, status: 422
        else
          if client_list["clients"]["total"].to_i > 0
            if client_list["clients"]["total"].to_i ==  1
              if client_list["clients"]["client"]['email'] == @job.lead_email
                @client = client
              end
            else
              client_list.first[1]['client'].each do |client|
                if client['email'] == @job.lead_email
                  @client = client
                end
              end
            end
          end
          if !@client.blank?
            @updateClient = freshbookconnection.client.update(:client => {
                                                                      :client_id => @client['client_id'],
                                                                      :first_name  => @job.lead_name,
                                                                      :organization => @job.lead_name,
                                                                      :email => @job.lead_email,
                                                                      :password => "password",
                                                                      :contacts =>  [
                                                                                      { 
                                                                                        :contact => {
                                                                                                      :email => @job.lead_email
                                                                                                    }
                                                                                      }
                                                                                    ]
                                                                    }
                                                        )
          else  
            @client = freshbookconnection.client.create(:client => {
                                                                      :first_name  => @job.lead_name,
                                                                      :organization => @job.lead_name,
                                                                      :email => @job.lead_email,
                                                                      :password => "password",
                                                                      :contacts => [{ :contact => {
                                                                      :email => @job.lead_email
                                                                    }}]
                                                        })
          end
          if params[:free_starter_kit].blank?
            @client_invoice = freshbookconnection.invoice.update(:invoice => {  :invoice_id => @invoice.freshbooks_invoice_id,
                                                                                :client_id => @client['client_id'],
                                                                                :organization => @job.lead_name,
                                                                                :po_number => @job.id,
                                                                                :notes => params[:invoice_info_body],
                                                                                :lines => [{ :line => {
                                                                                   :name         => params[:title_invoice],
                                                                                   :description  => params[:description_invoice],
                                                                                   :unit_cost    => params[:unit_cost],
                                                                                   :quantity     => params[:qty]
                                                                                 }}]
            })
          else
            @client_invoice = freshbookconnection.invoice.update(:invoice => {  :invoice_id => @invoice.freshbooks_invoice_id,
                                                                                :client_id => @client['client_id'],
                                                                                :po_number => @job.id,
                                                                                :organization => @job.lead_name,
                                                                                :notes => params[:invoice_info_body],
                                                                                :lines => [
                                                                                            {
                                                                                              :line => {
                                                                                                          :name => params[:title_invoice],
                                                                                                          :description => params[:description_invoice],
                                                                                                          :unit_cost => params[:unit_cost],
                                                                                                          :quantity => params[:qty]
                                                                                                        }
                                                                                            },
                                                                                            {
                                                                                              :line => {
                                                                                                          :name         => "Free kit",
                                                                                                          :description  => params[:free_starter_kit],
                                                                                                          :unit_cost    => 0,
                                                                                                          :quantity     => params[:qty]
                                                                                                        }
                                                                                            }
                                                                                          ]
            })
          end
          if !@client_invoice['inovice_id']
            @invoice.update(:payment_advise => params[:view_pa])
          end
        end
        render :text => "Done", :status => 200
      else
        render :text => 'Email Cant be blank', status: 422
      end
    end
  end

  def index
    add_breadcrumb "Invoices list", :manage_invoices_path
    # freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    #  @freshbook_invoices = freshbookconnection.invoice.list.to_json
    #  @freshbook_invoices =JSON.parse(@freshbook_invoices)["invoices"]
    #  @total = @freshbook_invoices["total"].to_i
    #  @invoice = Invoice.last
    #  if !@invoice.blank?
    #    @last_sync_inv_id = @invoice.last_sync_inv_id
    #    if !@last_sync_inv_id.blank?
    #      @num = @last_sync_inv_id[2..(@last_sync_inv_id.length)]
    #      if @total != 0
    #        if @total == 1
    #          @sys_inv = Invoice.find_by_freshbooks_invoice_id(@freshbook_invoices["invoice"]["invoice_id"])
    #          if @sys_inv.blank?
    #            number = @freshbook_invoices["invoice"]["number"]
    #            str = number[2..(number.length)]
    #            if str > @num
    #              @inv = Invoice.create(:freshbooks_invoice_id => @freshbook_invoices["invoice"]["invoice_id"],:invoice_number => @freshbook_invoices["invoice"]["number"], :job_id => @freshbook_invoices["invoice"]["po_number"], :last_sync_inv_id => @freshbook_invoices["invoice"]["number"]) 
    #            end  
    #          end  
    #        elsif @total > 1
    #          @freshbook_invoices["invoice"].each do |p|
    #            @sys_inv = Invoice.find_by_freshbooks_invoice_id(p["invoice_id"])
    #            if @sys_inv.blank?
    #              number = p["number"]
    #              str = number[2..(number.length)]
    #              if str > @num
    #                @inv = Invoice.create(:freshbooks_invoice_id => p["invoice_id"],:invoice_number => p["number"], :job_id => p["po_number"], :last_sync_inv_id => p["number"]) 
    #              end  
    #            end  
    #          end
    #        end    
    #      end  
    #    end
    #  elsif @invoice.blank?
    #    @freshbook_invoices["invoice"].each do |p|
    #      @sys_inv = Invoice.find_by_freshbooks_invoice_id(p["invoice_id"])
    #      if @sys_inv.blank?
    #        @inv = Invoice.create(:freshbooks_invoice_id => p["invoice_id"],:invoice_number => p["number"], :job_id => p["po_number"], :last_sync_inv_id => p["number"]) 
    #      end  
    #    end  
    #  end 
    #  Invoice.all.each do |i|
    #    @inv = freshbookconnection.invoice.get(:invoice_id => i.freshbooks_invoice_id)
    #    if @inv["error"]
    #      i.destroy
    #    end
    #  end
    respond_to do |format|
      format.html { render layout: "setting_data" }
      format.json { 
        render json: InvoicesDatatable.new(view_context) }
    end
  
  end

  # ----------------- JOB SHOW PAGE : CODE FOR ADD PAYMENT FROM JOB SHOW PAGE FOR PARTICULAR INVOICE ------------------- 
      # def get_freshbook_invoice
      #   if params[:freshbooks_invoice_id]
      #     freshbooks_invoice_id = params[:freshbooks_invoice_id]
      #     @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
      #     @invoice = @freshbookconnection.invoice.get(:invoice_id => freshbooks_invoice_id)
      #   end
      # end

  def destroy
    @invoice = Invoice.find_by(:invoice_number => params[:id])
    @job = @invoice.job_id
    @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    @freshbookconnection.invoice.delete(:invoice_id => @invoice.freshbooks_invoice_id)
    @invoice.destroy
    render :text => 0
  end

  def show
    add_breadcrumb "Invoices list", :manage_invoices_path
    @invoice = Invoice.find(params[:id])

    @freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    @freshbook_invoice = @freshbookconnection.invoice.get(:invoice_id => @invoice.freshbooks_invoice_id)
    if @freshbook_invoice["error"]
      @invoice.destroy
      redirect_to manage_invoices_path, alert: "Matchmaker and Freshbooks inovoices are not correctly sync." 
    end  
    # else
    #   @freshbook_payments = @freshbookconnection.payment.list(:invoice_id => @invoice.freshbooks_invoice_id)
    
    #   @freshbook_payments = @freshbook_payments["payments"]
    #   @total = @freshbook_payments["total"].to_i

    #   if @total != 0
    #     if @total == 1
    #       @payment = @invoice.payments.find_by_freshbooks_payment_id(@freshbook_payments["payment"]["payment_id"])
    #       if @payment.blank?
    #         Payment.create(:invoice_id => @invoice.id,:freshbooks_payment_id => @freshbook_payments["payment"]["payment_id"],:amount => @freshbook_payments["payment"]["amount"],:method_type => @freshbook_payments["payment"]["type"],:payment_date => @freshbook_payments["payment"]["date"],:note => @freshbook_payments["payment"]["notes"] )
    #       else
    #         @payment.update_attributes(:amount => @freshbook_payments["payment"]["amount"],:method_type => @freshbook_payments["payment"]["type"],:payment_date => @freshbook_payments["payment"]["date"],:note => @freshbook_payments["payment"]["notes"])
    #       end
    #     elsif @total > 1
    #       @freshbook_payments["payment"].each do |p|
    #         @payment = @invoice.payments.find_by_freshbooks_payment_id(p["payment_id"])
    #         if @payment.blank?  
    #           Payment.create(:invoice_id => @invoice.id,:freshbooks_payment_id => p["payment_id"],:amount => p["amount"],:method_type => p["type"],:payment_date => p["date"],:note => p["notes"] )
    #         else
    #           @payment.update_attributes(:amount => p["amount"],:method_type => p["type"],:payment_date => p["date"],:note => p["notes"] )
    #         end
    #       end  
    #     end
    #   end  
    # end   
    @payments = @invoice.payments 
    add_breadcrumb "Invoices "+@invoice.invoice_number, :manage_invoice_path
  end

  def freshbook_invoice
    if params[:online_payments_invoice_id]
      invoice_fb_id = Invoice.find_by_invoice_number(params[:online_payments_invoice_id])
      redirect_to "https://#{@api_setting.fb_api_url}/invoices/#{invoice_fb_id.freshbooks_invoice_id}", :target => "_blank"
      # redirect_to "https://swimming.freshbooks.com/invoices/#{invoice_fb_id.freshbooks_invoice_id}", :target => "_blank"
    else
      redirect_to "https://#{@api_setting.fb_api_url}/invoices/#{params[:invoice_id]}", :target => "_blank"
      # redirect_to "https://swimming.freshbooks.com/invoices/#{params[:invoice_id]}", :target => "_blank"
    end
  end

  def job_create_invoice
  end

  private
  def load_api_setting
    @api_setting = ApiSetting.first
  end
  def check_user_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      end
    else
      redirect_to manage_root_path
    end
  end
end
