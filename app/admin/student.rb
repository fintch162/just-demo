ActiveAdmin.register Student do

  active_admin_importable
  before_filter :check_user_permission

  controller do
    def permitted_params
      params.permit :utf8, :_method, :authenticity_token, :commit, :id,
                    :student => [:job_id, :name, :age, :sex, :age_month]
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

  form do |f|
    f.inputs "Student Details" do
      f.input :job_id, as: :select, collection: Job.all.collect{ |u| [u.id, u.id]}, :include_blank => "Select Job" 
      f.input :name, :placeholder => "Enter Name" 
      f.input :age, as: :select, collection: 1..60, :include_blank => "Select Year"
      f.input :age_month, as: :select, collection: 1..12, :include_blank => "Select Month"
      f.input :sex, :collection => [['M','M'], ['F','F']], as: :radio
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
