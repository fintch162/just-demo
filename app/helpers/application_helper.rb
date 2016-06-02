module ApplicationHelper
  def page_title
    if manage_controller_name == "invoices" && action == "show"
      @page_title || t("pages.#{manage_controller_name}.#{Invoice.find(params[:id]).invoice_number}.title", default: "#{manage_controller_name.humanize} #{Invoice.find(params[:id]).invoice_number}")
    elsif manage_controller_name == "jobs" && action == "show"
      begin
        @page_title || t("pages.#{manage_controller_name}.#{Job.find(params[:id]).id}.title", default: "#{Job} #{Ref} #{Job.find(params[:id]).id}")
      rescue Exception => e
      end 
    
    elsif manage_controller_name == "instructors" && action == "show" || manage_controller_name == "instructors" && action == "instructor_job_taken"
      @page_title || t("pages.#{manage_controller_name}.#{Instructor.find(params[:id]).id}.name", default: "#{Instructor.find(params[:id]).name}")
    
    elsif manage_controller_name == "terms_and_conditions"
       @page_title || t("pages.#{manage_controller_name}", default: "Terms & Conditions")
    
    elsif manage_controller_name == "manual_payments" && params[:action] == "uncommitted_payments"
      @page_title || "Uncommitted Payment"

    elsif manage_controller_name == "generate_forms" && params[:action] == "generator"
      @page_title || "Generate Form"
    
    else
      if manage_controller_name != "db_messages"
        @page_title || t("pages.#{manage_controller_name}.#{action}.title", default: "#{manage_controller_name.humanize} #{action.humanize}")
      end
    end
  end

  def page_description
    @page_description || t("pages.#{manage_controller_name}.#{action}.description", default: "")
  end

  def manage_controller_name
    @manage_controller_name ||= params[:controller].gsub(/manage\//,'')
  end

  def action
    params[:action]
  end
  def title(page_title)
    # if title.present?
      # content_for :title, title
    # else
      content_for :title, page_title.to_s
    # end
  end
  def row_filters(columns, *filters)
    simple_form_for :search, url: "#" do |f| #useing simple form to grab it's helpers
      content_tag :div, id: "row-filters" do
        content_tag :table do
          content_tag :tr do
            tds = []
            columns.each do |column|
              tds << build_filter_column(column, f, filters)
            end
            tds.join.html_safe
          end
        end
      end
    end
  end

  def build_filter_column(column, form, filters)
    filter = filters.find{ |filt| filt[:field] == column[:field].to_sym}
    filter ? build_filter(form, filter) : content_tag(:td, nil)
  end

  def build_filter(form, filter)
    content_tag :td do
      field = filter.delete(:field)
      filter[:label] = false
      html_opts = filter[:input_html] || {}
      html_opts["data-field"] = filter.delete(:filter)
      html_opts[:class] ||= "filter form-control input-sm"
      filter[:input_html] = html_opts
      form.input field, filter
    end
  end

  def yes_no(param)
    "#= (data.#{param}==false) ? 'no' : 'yes' #"
  end

  def yes_no_icon(param)
    yes_icon = content_tag :i, nil, class: "fa fa-check"
    no_icon = content_tag :i, nil, class: "fa fa-times"

    "#= (data.#{param}==false) ? '#{no_icon}' : '#{yes_icon}' #"
  end

  def action_links(actions)
    actions.map do |key, title, method='get', options={}|
      attrs = { method: method, class: "k-button k-button-icontext" }
      attrs[:confirm] = 'Are you sure?' if method == 'delete'
      attrs.merge! options
      link_to title, "#:data.#{key}#", attrs
    end.join(' ')
  end

  def default_action_links
    action_links([[:edit_link, 'Edit'], [:delete_link, 'Delete', 'delete'], [:view_link, "View"]])
  end

  def active_for(*vals)
    options = vals.extract_options!
    opt_action = options[:action]
    if vals.include?(manage_controller_name)
      if opt_action
        "active" if params[:action] == action
      else
        "active"
      end
    end
  end

  def add_button(klass)
    link_to("Add #{klass.to_s.humanize}", url_for(controller: klass.to_s.underscore.pluralize, action: "new"), class: "btn btn-primary").html_safe
  end

  def kendo_settings(columns, klass, options = {})
    klass_name = klass.to_s
    settings = {
      bind: "source: #{klass_name.underscore.pluralize}",
      columns: columns.to_json,
      editable: options[:editable] || "false",
      pageable: "true",
      sortable: "true",
      scrollable: "false",
      filterable: "false",
      role: "grid",
      toolbar: options[:toolbar] || ""
    }

    content_tag :div, id: "#{klass_name.camelize(:lower)}List" do
      content_tag(:div, nil, data: settings).html_safe
    end.html_safe
  end

  def search_bar(query, placeholder = nil)
    placeholder ||= "search by " + query.split("_")[0..-2].join(" ")
    content_tag :input, nil, class: "form-control filter live", type: "search", placeholder: placeholder, "data-field" => query
  end

  #kendo helpers
  def kendo_field(key, options = {})
    hash = { field: key }
    hash.merge!(options)
    hash[:title] ||=  key.to_s.humanize.gsub(/id/,"")
    hash
  end

  def kendo_fields(*args)
    options = args.extract_options!
    fields = args.map{|arg| kendo_field(arg)}
    fields << kendo_field("Actions", title: "", template: default_action_links, sortable: false) if options[:default_actions]

    command = options[:command]
    fields << {command: command.map{|key| {name: key} }} if command
    fields
  end

  def week_days
    t("week_days")
  end

  def solid_replace(p_str,p_find,p_replace)
    arr = p_str.split(p_find);
    return arr.join(p_replace).html_safe;
  end

   def user_accountant_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      elsif current_admin_user.coordinator?
        redirect_to manage_root_path
      end
    end
  end

  def user_manage_permission
    if admin_user_signed_in?
      if current_admin_user.instructor?
        redirect_to instructor_root_path
      elsif current_admin_user.admin?
        redirect_to admin_root_path
      elsif current_admin_user.accountant?
        redirect_to accountant_root_path
      end
    end
  end

  #returns "1 february 2015" if you pass "feb-15"
  def get_beginning_of_month(date)
    century = Date.today.strftime('%Y')[0..1]
    date = Date.parse(date.gsub("-"," "+century))
    return date
  end
  def sort_group_classes_by_day(group_classes)
    sunday_classes = []
    week_day_classes = []
    group_classes.each do |group_class|
      if group_class.day == 0
        sunday_classes << group_class
      else
         week_day_classes << group_class
      end
    end
    week_day_classes = week_day_classes + sunday_classes
    return week_day_classes
  end
end