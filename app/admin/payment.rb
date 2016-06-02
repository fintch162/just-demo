ActiveAdmin.register Payment do
  active_admin_importable
  permit_params :invoice_id, :freshbooks_payment_id, :amount, :expense, :note, :method_type, :mode, :payment_date

  before_filter :check_user_permission

  controller do
    def permitted_params
      params.permit :utf8, :_method, :authenticity_token, :commit, :id,
                    :payment => [:invoice_id, :freshbooks_payment_id, :amount, :expense, :note, :method_type, :mode, :payment_date]
    end

    def check_user_permission
      if admin_user_signed_in?
        if current_admin_user.coordinator?
          redirect_to manage_root_path
        elsif current_admin_user.instructor?
          redirect_to instructor_root_path
        end
      end
    end
  end

  csv do
    column :id
    column :invoice_id
    column :freshbooks_payment_id
    column :amount
    column :expense
    column :note
    column :method_type
    column :payment_date
    column :mode
    column :created_at
    column :updated_at
  end


  index do
    selectable_column
    id_column
    column :invoice_id
    column :freshbooks_payment_id
    column :amount
    column :expense
    column :note
    column :method_type
    column :payment_date
    column :mode
    actions
  end


  form do |f|
    f.inputs "Payment Details" do
      f.input :invoice_id, as: :select, collection: Invoice.all.collect{ |u| [u.invoice_number, u.id]}
      f.input :freshbooks_payment_id
      f.input :amount
      f.input :expense
      f.input :note
      f.input :method_type
      f.input :mode
      f.input :payment_date, :as => :date_picker
    end
    f.actions
  end

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
