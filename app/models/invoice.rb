class Invoice < ActiveRecord::Base
  has_many :payments,:dependent => :destroy
  belongs_to :job
  before_create :generate_unique_payment_number

  def generate_unique_payment_number
    u_number = Array.new(5){rand(36).to_s(36)}.join
    self.u_sec_number = u_number
  end

  def paypal_url(return_url, job_id, referral_amt, notify_url, invoice_id)
    values = { 
      :business => ApiSetting.first.paypal_user_email,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :no_shipping => 1,
      :no_note => 1
    }

    values.merge!({ 
      "amount_1" => referral_amt,
      "item_name_1" => "REF - "+ job_id + " (Invoice " + invoice_id + ")",
      "currency_code" => "SGD"
    })

     # "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
      "https://www.paypal.com/cgi-bin/webscr?" + values.to_query
  end
end
