class Manage::TermsAndConditionsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  before_action :set_terms_and_condition, only: [:show, :edit, :update, :destroy]
  add_breadcrumb "Home", :manage_root_path
  add_breadcrumb "Terms & Conditions", :manage_terms_and_conditions_path

  def index
    @terms_and_conditions = TermsAndCondition.all
  end
  def new
    add_breadcrumb "Add New", :new_manage_terms_and_condition_path
    @status = ["Active", "Inactive"]
    @terms_and_condition = TermsAndCondition.new
  end

  def edit
    @status = ["Active", "Inactive"]
  end

  def update
    respond_to do |format|
      if @terms_and_condition.update(terms_and_condition_params)
        format.html { redirect_to manage_terms_and_conditions_path}
      else
        format.html { render :edit }
      end
    end 
  end

  def create
    @term_and_conditon = TermsAndCondition.new(terms_and_condition_params)
    if @term_and_conditon.save
      redirect_to manage_terms_and_conditions_path
    else
      respond_to json: {}, status:  422
    end
  end
  private

    def terms_and_condition_params
      params.require(:terms_and_condition).permit(:status, :title, :content)
    end 
    def set_terms_and_condition
      @terms_and_condition = TermsAndCondition.find(params[:id])
    end   
end

