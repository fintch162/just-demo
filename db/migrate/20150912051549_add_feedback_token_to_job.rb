class AddFeedbackTokenToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :feedback_token, :string
  end
end
