class Instructor::HideShowColumnsController < Instructor::BaseController
  def update_columns
    if params[:columnName] == "updateall"

      @hide_show_column = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
      @hide_show_column.update(table_name: "group_class_list", venue: "true", age_group: "true", level: "true",
                                fee: "true", fee_type: "true", students: "true", max_slot: "true",
                                vacancy: "true")
      render :text => ['hideVenue','hideAgeGroup', 'hideLevel', 'hideFee', 'hideFeeType', 'hideStudents', 'hideMaxSlot', 'hideVacancy']
    else

      column_name = params[:columnName].gsub(/[-]/, '_').downcase
      is_selected = params[:isSelected]

      column_name = "profile_pic" if column_name == "profile_picture"
      column_name = "join_date" if column_name == "joined_date"

      @hide_show_column = current_admin_user.hide_show_columns.find_by_table_name(params[:tableName])
    
      if @hide_show_column.update_attributes(column_name => is_selected)
        render :text => "Done"
      end
    end
  end
end