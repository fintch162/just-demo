module Filterable
  def filter(params)
    scope = ransack(params[:search]).result
    scope = scope.order("#{params[:sort][:field]} #{params[:sort][:dir]}") if params[:sort]
    scope = scope.paginate(page: params[:page], per_page: params[:per_page])
    scope
  end
end