class AddReferredToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :referred, :string
  end
end
