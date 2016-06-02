class AccountantReportsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end
  def as_json(options = {})

   {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: payment_reports.count,
    iTotalDisplayRecords: payment_reports.count,
    aaData: data
   }
  end
  private
    def data
      @payment_reports = payment_reports
      @fetch_payment_process_data=SsaPaymentProcessFee.check_data
      @payment_reports.map.each do |payment|
        @app_trx = 0
        @payment_name=[]
        @payment_fee_amount=[]
        @mark=['diff']
        if @fetch_payment_process_data
          payment[:data].each do |data|
            if data.status == "Paid"
              @app_trx = @app_trx +1
              payment_fee = SsaPaymentProcessFee.check_payment_name(data[:paid_by], data[:created_at])
              if payment_fee.present?
                if payment_fee.class!=Array
                  if @payment_name.include?(payment_fee.payment_name)
                    name_index = @payment_name.index(payment_fee.payment_name)
                    n =  @payment_fee_amount[name_index].to_f + ((data[:amount]*payment_fee.processing_fee)/100).to_f + payment_fee.transaction_fee.to_f
                    @payment_fee_amount[name_index] = "%.2f" % n
                  else
                    @payment_name << payment_fee.payment_name
                    @payment_fee_amount << "%.2f" % (data[:amount]*payment_fee.processing_fee/100+payment_fee.transaction_fee)
                  end
                end
              end
            end
          end
          # @all_data=SsaPaymentProcessFee.where("from_date <= ?",payment[:date].strftime("%Y-%m-%d"))
          # @all_data.each do |data|
          #   @payment_name << data.payment_name
          #   @payment_fee_amount << data.transaction_fee
          # end
        end
        amount=payment[:data].map{ |s| s.amount.to_f }.reduce(0, :+)
        f= @payment_fee_amount.map{ |s| s.to_f }.reduce(0, :+)
        fee = "%.2f" % f
        gross_amount=amount.to_f-fee.to_f
        [
          payment[:date].strftime("%d %b %Y"),
          '$'+ amount.to_s,
          '$'+ fee.to_s,
          '$'+ gross_amount.to_s,
          payment[:data].count,
          @app_trx,
          @payment_name + @mark + @payment_fee_amount
        ] 
      end
    end

    def fetch_payment_reports
      @beginning_date=Date.today.beginning_of_month.beginning_of_day
      @end_date=Date.today.end_of_month.end_of_day
      payment_reports = FeePaymentNotification.fee_payment(@beginning_date,@end_date).includes(:fee)
      payment_reports += PaymentNotification.payment(@beginning_date,@end_date)
      payment_reports += AwardTestPaymentNotification.award_test_payment(@beginning_date,@end_date)
     

      if params[:sSearch]== "undefined"
        if params[:choose_month].present? && params[:choose_month] != "" 
          @beginning_date=params[:choose_month].to_date
          @end_date=params[:choose_month].to_date.end_of_month.end_of_day.end_of_month
          # payment_reports = payment_reports.where(:created_at => @beginning_date..@end_date)
          payment_reports = FeePaymentNotification.fee_payment(@beginning_date,@end_date).includes(:fee)
          payment_reports += PaymentNotification.payment(@beginning_date,@end_date)
          payment_reports += AwardTestPaymentNotification.award_test_payment(@beginning_date,@end_date)
        end
      end
      my_data = []
      payment_reports.group_by_day(&:created_at).to_a.reverse.map do |date,data|
        my_data << {:date=> date,:data => data} if data.count > 0
      end
      payment_reports = my_data
    end

    def payment_reports
      @payment_reports ||= fetch_payment_reports
    end

    def page
      params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[created_at fee_id amount paid_by status name]
      columns[params[:iSortCol_0].to_i]
    end
    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end