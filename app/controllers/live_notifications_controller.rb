require 'reloader/sse'

class LiveNotificationsController < ApplicationController
  include ActionController::Live
  def index
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)
    @last_updated = ""
    last_inv_id = params[:after].to_i;
    begin
      # status = ["Completed", "Paid", "completed", "paid"]
      PaymentNotification.uncached do
        @last_updated = PaymentNotification.where('id > ?', last_inv_id)
        sse.write(@last_updated, event: 'message')
      end
    rescue IOError
    ensure
      sse.close
    end
  end
end