class Manage::FreshbooksController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
	before_action :load_api_setting
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Jobs", :manage_jobs_path
  add_breadcrumb "FreshBooks Invoice", :manage_freshbooks_invoice_path
	def index
		freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    # freshbook_invoice = freshbookconnection.invoice.list
    # @invoices = freshbook_invoice.first[1]['invoice']
    session[:current_page] = 1
    freshbook_invoice = freshbookconnection.invoice.list :page => 1, :per_page => 20
    fresh = freshbook_invoice
    @total = freshbook_invoice["invoices"]["total"]
    session[:total_page] = freshbook_invoice["invoices"]["pages"]
    @inv_retnn = fresh["invoices"]["invoice"]
    @invoices = @inv_retnn
    
    render :layout => "setting_data"
    
  end

  def manage_invoice_prev
    if session[:current_page] == 1
      session[:current_page] = 1
      @page_number = session[:current_page]
    else
      @page_number = session[:current_page] - 1
    end
    
    freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    freshbook_invoice = freshbookconnection.invoice.list :page => @page_number, :per_page => 20
    fresh = freshbook_invoice
    @inv_retnn = fresh["invoices"]["invoice"]
    session[:current_page] = @page_number
  end
  def manage_invoice_next
    if session[:total_page] == session[:current_page]
      session[:current_page] = session[:total_page]
      @page_number = session[:current_page]
    else
      @page_number = session[:current_page] + 1
    
    end
    freshbookconnection = FreshBooks::Client.new(@api_setting.fb_api_url, @api_setting.fb_authentication_token)
    freshbook_invoice = freshbookconnection.invoice.list :page => @page_number, :per_page => 20
    fresh = freshbook_invoice
    @inv_retnn = fresh["invoices"]["invoice"]
    session[:current_page] = @page_number
  end
	private
  	def load_api_setting
    	@api_setting = ApiSetting.first
  	end
end