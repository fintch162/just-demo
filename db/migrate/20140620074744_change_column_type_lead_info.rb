class ChangeColumnTypeLeadInfo < ActiveRecord::Migration
  def change
    change_column :jobs, :lead_info, :string
  end
end
