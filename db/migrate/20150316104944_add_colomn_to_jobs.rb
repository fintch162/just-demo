class AddColomnToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :bank_transfer, :boolean , default: false
  end
end
