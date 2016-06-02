ActiveAdmin.register RegistrationPackage do

  active_admin_importable
  permit_params :no_of_student ,:is_lady,:price,:age_group_id
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
    column :no_of_student
    column :is_lady
    column :price
    column "Age Group" do |registration_package|
      if registration_package.age_group.present?
        age_group = AgeGroup.find(registration_package.age_group).title
        link_to age_group, admin_age_group_path(registration_package.age_group)
      end
    end
    actions
  end

  form do |f|
    f.inputs "Invoice Details" do
      f.input :no_of_student
      f.input :is_lady , :label => "Coach" , :collection => [['lady','true'], ['male','false']], as: :radio
      f.input :price
      f.input :age_group_id, :label => "Age Group", as: :select, collection: AgeGroup.where("LOWER(title) IN (?)", ['adult', 'kids']).collect{ |u| [u.title, u.id] }, :include_blank => "Select Age Group"
    end
    f.actions
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
