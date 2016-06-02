class AddPaymentAdviseBodyToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :payment_advise_body, :text
  end
end
