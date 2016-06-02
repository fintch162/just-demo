class RevertSomeMessageColumn < ActiveRecord::Migration
  def change
    rename_column :messages, :to_number, :to
    rename_column :messages, :content, :message_description

    change_column :messages, :from_number, :string
    change_column :messages, :time_created, :string
  end
end
