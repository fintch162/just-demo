class DbMessageOutgoingDatatable
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
      if message.to_number.include?('+')
        if message.to_number.include?("^")
          @to_number = message.to_number[4..-1]
        else
          @to_number = message.to_number[3..-1]
        end
      else
        if message.to_number.include?("^")
          @to_number = message.to_number.gsub('^', '')
        else
          @to_number = message.to_number
        end
      end
      [
        @to_number,
        message.bulk_sms_id,
        link_to(message.message_description, v.manage_conversation_message_path(@to_number)),
        message.status,
        message.time_created.strftime('%d/%m/%Y'),
        message.time_created.strftime('%I:%M %P'),
      ]
    end
  end
  def fetch_messages
    @coordinator_api_setting = CoordinatorApiSetting.find_by_coordinator_id(params[:coordinator])
    direction = ["Outgoing", "outgoing"]
    messages = Message.where(:coordinator_id => params[:coordinator]).where("direction IN (?)", direction).where("to_number LIKE ? OR from_number LIKE ?", "%#{@coordinator_api_setting.telerivet_phone_number}%", "%#{@coordinator_api_setting.telerivet_phone_number}%").order("time_created DESC").order("#{sort_column} #{sort_direction}")
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
