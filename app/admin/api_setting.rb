ActiveAdmin.register ApiSetting do
    actions :all, :except => [:destroy]
    permit_params :telerivet_project_id, :telerivet_phone_id, :telerivet_api_key, :fb_api_url, :fb_authentication_token, :xfers_key, :paypal_user_email, :student_view_url, :google_client_id, :google_client_secret

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
      f.inputs "Telerivet Settings" do
        f.input :telerivet_project_id
        f.input :telerivet_phone_id
        f.input :telerivet_api_key
      end

      f.inputs "Freshbook Settings" do
        f.input :fb_api_url
        f.input :fb_authentication_token
      end

      f.inputs "Xfers.IO Settings" do
        f.input :xfers_key
      end

      f.inputs "Paypal Settings" do
        f.input :paypal_user_email, :label => "Paypal Email"
      end

      f.inputs "Student View Url" do
        f.input :student_view_url, :label => "Student View Url", :placeholder => "ex: http://google.com"
      end

      f.inputs "Google Contact Api Settings" do
        f.input :google_client_id
        f.input :google_client_secret
      end

      f.actions
    end
  
end