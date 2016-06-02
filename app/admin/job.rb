ActiveAdmin.register Job do

  active_admin_importable

  before_filter :check_user_permission

  controller do
    def permitted_params
      params.permit :utf8, :_method, :authenticity_token, :commit, :id,
      :job => [ :post_date, :instructor_id, :preferred_time, :referral, 
                :par_pax, :fee_total, :age_group, :class_level, :start_date, :class_type, :other_venue, 
                :lead_email, :lead_contact, :lead_name, :day_of_week, :customer_contact, :customer_name, 
                :first_attendance, :goggles_status, :lock_date, :message_to_instructor, :job_status, 
                :message_to_customer, :coordinator_notes, :lead_info, :lead_address, :lesson_count, 
                :fee_type_id, :class_time, :completed_by, :venue_id, :show_names, :free_goggles, 
                :lady_instructor, :instructor_name, :instructor_contact]
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

  # permit_params :post_date, :instructor_id, :preferred_time, :referral, 
  # :par_pax, :fee_total, :age_group, :class_level, :start_date, :class_type, :other_venue, 
  # :lead_email, :lead_contact, :lead_name, :day_of_week, :customer_contact, :customer_name, 
  # :first_attendance, :goggles_status, :lock_date, :message_to_instructor, :job_status, 
  # :message_to_customer, :coordinator_notes, :lead_info, :lead_address, :lesson_count, 
  # :fee_structure, :class_time, :completed_by, :venue_id, :show_names, :free_goggles, 
  # :lady_instructor, :instructor_name, :instructor_contact

  week_days = [["Monday", 1], ["Tuesday",2], ["Wednesday", 3], ["Thursday", 4], ["Friday", 5], ["Saturday" , 6], ["Sunday" , 0]]
  week_days_id = ["Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  csv do
    column :id
    column :post_date
    column :instructor_id
    column :instructor_name
    column :instructor_contact
    column :preferred_time
    column :referral
    column :par_pax
    column :fee_total
    column :age_group
    column :class_level
    column :start_date
    column :class_type
    column :other_venue
    column :lead_email
    column :lead_contact
    column :lead_name
    column :day_of_week
    column :customer_contact
    column :customer_name
    column :first_attendance
    column :goggles_status
    column :lock_date
    column :message_to_instructor
    column :job_status
    column :message_to_customer
    column :coordinator_notes
    column :lead_info
    column :lead_address
    column :lesson_count
    column :fee_type_id
    column :class_time
    column :completed_by
    column :venue_id
    column :show_names
    column :free_goggles
    column :lady_instructor
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs "Job Details" do
      f.input :post_date
      f.input :instructor_id, as: :select, collection: Instructor.all.collect{ |u| [u.name, u.id]}
      f.input :instructor_name
      f.input :instructor_contact
      f.input :preferred_time
      f.input :referral
      f.input :par_pax
      f.input :fee_total
      f.input :age_group, as: :select, collection: AgeGroup.all.collect{ |u| [u.title, u.id]}
      f.input :class_level, as: :select, collection: Level.all.collect{ |u| [u.title, u.id]}
      f.input :start_date, :as => :date_picker
      f.input :class_type, as: :select, collection: ClassType.all.collect{ |u| [u.title, u.id]}
      f.input :other_venue
      f.input :lead_email
      f.input :lead_contact
      f.input :lead_name
      f.input :day_of_week, :as => :select, :collection => week_days
      f.input :customer_contact
      f.input :customer_name
      f.input :first_attendance
      f.input :goggles_status
      f.input :lock_date
      f.input :message_to_instructor
      f.input :job_status
      f.input :message_to_customer
      f.input :coordinator_notes
      f.input :lead_info
      f.input :lead_address
      f.input :lesson_count
      f.input :fee_type_id, :label => "Fee Type", as: :select, collection: FeeType.all.collect{ |u| [u.name, u.id]}
      f.input :class_time
      f.input :completed_by, :as => :date_picker
      f.input :venue_id, as: :select, collection: Venue.all.collect{ |u| [u.name, u.id]}
      f.input :show_names
      f.input :free_goggles
      f.input :lady_instructor

      # f.inputs do
      #   f.has_many :students, :allow_destroy => true do |cf|
      #     cf.input :name
      #   end
      # end

    end
    f.actions
  end

  index do
    selectable_column
    id_column

    column :post_date
    column "Instructor" do |job|
      if job.instructor_id.present?
        instructor = Instructor.find(job.instructor_id).name
        link_to instructor, admin_instructor_path(job.instructor_id) 
      end
    end
    # column :venue_id
    column "Venue" do |job|
      if job.venue_id.present?
        venue = Venue.find(job.venue_id).name
        link_to venue, admin_venue_path(job.venue_id)
      end
    end
    column :preferred_time
    column :referral
    column :par_pax
    column :fee_total
    column "Age Group" do |job|
      if job.age_group.present?
        age_group = AgeGroup.find(job.age_group).title
        link_to age_group, admin_age_group_path(job.age_group)
      end
    end
    column "Class Level" do |job|
      if job.class_level.present?
        class_level = Level.find(job.class_level).title
        link_to class_level, admin_level_path(job.class_level)
      end
    end
    column :start_date
    column "Class Type" do |job|
      if job.class_type.present?
        class_type = ClassType.find(job.class_type).title
        link_to class_type, admin_class_type_path(job.class_type)
      end
    end
    column :other_venue
    column :lead_email
    column :lead_contact
    column :lead_name
    column "Day Of Week" do |job| 
      week_days_id[job.day_of_week.to_i]
    end
    column :customer_contact
    column :customer_name
    column :first_attendance
    column :goggles_status
    column :lock_date
    column :message_to_instructor
    column :job_status
    column :message_to_customer
    column :coordinator_notes
    column :lead_info
    column :lead_address
    column :lesson_count
    column "Fee Type" do |job|
      if job.fee_type_id.present?
        class_type = FeeType.find(job.fee_type_id).name
      end
    end
    column "Class Time" do |job|
      job.class_time.strftime("%I:%M %p") if job.class_time?
    end
    column :completed_by
    column :show_names
    column :free_goggles
    column :lady_instructor
    column :instructor_name
    column :instructor_contact
    column :created_at
    column :updated_at
    actions
  end
  show do |job|
    attributes_table do
      row :post_date
      row "Instructor" do |job|
        if job.instructor_id.present?
          instructor = Instructor.find(job.instructor_id).name
          link_to instructor, admin_instructor_path(job.instructor_id)
        end
      end
      row "Venue" do |job|
        if job.venue_id.present?
          venue = Venue.find(job.venue_id).name
          link_to venue, admin_venue_path(job.venue_id)
        end
      end
      row :preferred_time
      row :referral
      row :par_pax
      row :fee_total
      row "Age Group" do |job|
        if job.age_group.present?
          age_group = AgeGroup.find(job.age_group).title
          link_to age_group, admin_age_group_path(job.age_group)
      
        end
      end
      row "Class Level" do |job|
        if job.class_level.present?
          class_level = Level.find(job.class_level).title
          link_to class_level, admin_level_path(job.class_level)
        end
      end
      row :start_date
      row "Class Type" do |job|
        if job.class_type.present?
          class_type = ClassType.find(job.class_type).title
          link_to class_type, admin_class_type_path(job.class_type)
        end
      end
      row :other_venue
      row :lead_email
      row :lead_contact
      row :lead_name
      row "Day Of Week" do |job| 
        week_days_id[job.day_of_week.to_i]
      end
      row :customer_contact
      row :customer_name
      row :first_attendance
      row :goggles_status
      row :lock_date
      row :message_to_instructor
      row :job_status
      row :message_to_customer
      row :coordinator_notes
      row :lead_info
      row :lead_address
      row :lesson_count
      row "Fee Type" do |job|
        if job.fee_type_id.present?
          class_type = FeeType.find(job.fee_type_id).name
        end
      end
      row "Class Time" do |job|
        job.class_time.strftime("%I:%M %p") if job.class_time?
      end
      row :completed_by
      row :show_names
      row :free_goggles
      row :lady_instructor
      row :instructor_name
      row :instructor_contact
      row :created_at
      row :updated_at
    end
    active_admin_comments
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
