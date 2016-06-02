ActiveAdmin.register Accountant do
   permit_params :email, :password, :password_confirmation, :name

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
    column :name
    column :email
    actions
  end

  filter :name
  filter :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end


end
