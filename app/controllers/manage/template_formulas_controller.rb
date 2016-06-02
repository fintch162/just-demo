class Manage::TemplateFormulasController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  respond_to :html, :json
  def create
    @template_formula = TemplateFormula.new(:condition_title => params[:condition_title], :condition_formula => params[:condition_formula])
    @template_formula.save
    render :text => @template_formula
  end

  def update
    @template_formula = TemplateFormula.find(params[:id])
    condition_title = params[:condition_title]
    condition_formula = params[:condition_formula]
    @template_formula.update_attributes(:condition_title => params[:condition_title], :condition_formula => params[:condition_formula])
    render :text => @template_formula
  end
end
