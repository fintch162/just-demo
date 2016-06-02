class DbMessageIncommingDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def v
    @view
  end  
 
  def as_json(options = {})
   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: Instructor.count,
    iTotalDisplayRecords: messages.total_entries,
    aaData: data
   }
  end

private
  def data
    @messages = messages
    @messages.to_a.map do |message|
      if message.from_number.include?('+')
        if message.from_number.include?("^")
          @from_number = message.from_number[4..-1]
        else
          @from_number = message.from_number[3..-1]
        end
      else
        if message.from_number.include?("^")
          @from_number = message.from_number.gsub('^', '')
        else
          @from_number = message.from_number
        end
      end
      [
        "",
        @from_number,
        link_to(message.message_description, v.manage_conversation_message_path(@from_number)),
        message.time_created.strftime('%d/%m/%Y'),
        message.time_created.strftime('%I:%M %P'),
      ]
    end
  end
  def fetch_messages
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(params[:coordinator])
    diraction = ["incoming", "Incoming"]
    messages = Message.where(:coordinator_id => params[:coordinator]).where("direction IN (?)", diraction).where("to_number LIKE ? OR from_number LIKE ?", "%#{@coordinator_api_setting.telerivet_phone_number}%", "%#{@coordinator_api_setting.telerivet_phone_number}%").order("time_created DESC").order("#{sort_column} #{sort_direction}")
    messages = messages.page(page).per_page(per_page)
  
    if params[:sSearch].present?
        messages = messages.where("LOWER(message_description) LIKE :search or LOWER(from_number) LIKE :search",search: "%#{params[:sSearch].downcase}%")
    end
   
    messages
  end

  def messages
    @messages ||= fetch_messages
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id name mobile email]
    columns[params[:iSortCol_0].to_i]
  end
  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
