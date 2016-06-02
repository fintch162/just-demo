class RemoveIonicRequestFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :ionic_request, :string
  end
end
