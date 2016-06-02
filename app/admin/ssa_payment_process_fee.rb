ActiveAdmin.register SsaPaymentProcessFee do
  permit_params :payment_name, :from_date, :transaction_fee, :processing_fee

  index do
    selectable_column
    id_column
    column :payment_name
    column "Date(from)" do |date|
      date.from_date.strftime("%d/%m/%y")
    end
    column "Transaction Fee" do |fee|
     '$' + fee.transaction_fee.to_s + '0'
    end
    column "Processing Fee" do |fee|
      fee.processing_fee.to_s + '%'
    end
    actions
  end

  show do |group_class|
    attributes_table do
      row :payment_name
      row "Date(from)" do |date|
        date.from_date.strftime("%d/%m/%y")
      end
      row "Transaction Fee" do |fee|
        '$' + fee.transaction_fee.to_s+ '0'
      end
      row "Processing Fee" do |fee|
        fee.processing_fee.to_s  + '%'
      end
    end
  end

  form do |f|
    f.inputs "New Ssa Payment Process Fee" do
      f.input :payment_name, :label => "Payment Name", as: :select, collection: PaymentNotification.where.not(:paid_by=> nil).where.not(:paid_by => "").pluck(:paid_by).uniq, :include_blank => "Select Payment Name"
      f.input :from_date
      f.input :transaction_fee
      f.input :processing_fee
    end
    f.actions
  end

end
