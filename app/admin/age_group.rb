ActiveAdmin.register AgeGroup do
  active_admin_importable
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

  permit_params :title

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  filter :title
end
