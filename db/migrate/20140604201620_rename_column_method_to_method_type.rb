class RenameColumnMethodToMethodType < ActiveRecord::Migration
  def change
    rename_column :payments, :method, :method_type
  end
end
