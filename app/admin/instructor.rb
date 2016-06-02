ActiveAdmin.register Instructor do
  active_admin_importable
  permit_params :name, :mobile, :email, :password, :password_confirmation, :gender, :short_name

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

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :mobile
    column :gender
    column :short_name
    actions
  end

  form do |f|
    f.inputs "Instructor Details" do
      f.input :name
      f.input :mobile
      f.input :gender, :collection => ["Male", "Female"], :as => :select
      f.input :short_name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  filter :name
  filter :mobile
end
