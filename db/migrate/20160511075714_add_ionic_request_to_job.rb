class AddIonicRequestToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :ionic_request, :string
  end
end
