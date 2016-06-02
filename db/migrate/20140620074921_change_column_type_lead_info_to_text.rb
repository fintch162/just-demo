class ChangeColumnTypeLeadInfoToText < ActiveRecord::Migration
  def change
    change_column :jobs, :lead_info, :text
  end
end
