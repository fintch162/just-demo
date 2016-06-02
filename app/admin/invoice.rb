ActiveAdmin.register Invoice do
  active_admin_importable
  permit_params :freshbooks_invoice_id, :invoice_number,:job_id


  before_filter :check_user_permission

  controller do
    def permitted_params
      params.permit :utf8, :_method, :authenticity_token, :commit, :id,
                    :invoice => [:freshbooks_invoice_id, :invoice_number,:job_id]
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
    column :invoice_number
    column :freshbooks_invoice_id
    column :job_id
    column :created_at
    column :updated_at
  end

  index do
    selectable_column
    id_column
    column :invoice_number
    column :freshbooks_invoice_id
    actions
  end

  form do |f|
    f.inputs "Invoice Details" do
      f.input :job_id, as: :select, collection: Job.all.collect{ |u| [u.id, u.id]}
      f.input :invoice_number
      f.input :freshbooks_invoice_id
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
