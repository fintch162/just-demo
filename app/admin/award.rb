ActiveAdmin.register Award do
  menu parent: "Lists"

  before_filter :check_user_permission

  controller do
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
   form do |f|
      f.inputs "Details" do
        f.input :name
        f.input :desciption
        f.input :image, :as => :file
      end
      f.actions
    end

end
