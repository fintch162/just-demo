class RemoveSlugFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :slug, :string
  end
end
