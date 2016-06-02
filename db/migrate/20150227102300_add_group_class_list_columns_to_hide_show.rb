class AddGroupClassListColumnsToHideShow < ActiveRecord::Migration
  def change
    add_column :hide_show_columns, :age_group, :boolean, default: true
    add_column :hide_show_columns, :level, :boolean, default: true
    add_column :hide_show_columns, :fee, :boolean, default: true
    add_column :hide_show_columns, :fee_type, :boolean, default: true
    add_column :hide_show_columns, :students, :boolean, default: true
    add_column :hide_show_columns, :max_slot, :boolean, default: true
    add_column :hide_show_columns, :vacancy, :boolean, default: true
  end
end
