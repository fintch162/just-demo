ActiveAdmin.register GroupClass do
    active_admin_importable
    permit_params :day, :time, :duration, :level_id, :instructor_id, :venue_id, :age_group_id, :class_type_id, :lesson_count, :remarks, :fee , :fee_type_id
    
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

    
    csv :force_quotes => true do
      column :id
      column :day
      column :time do |obj|
        obj.time.localtime.strftime("%I:%M %p")
      end
      column :duration
      column("venue_id") { |group_class| group_class.venue.id }
      column("instructor_id") { |group_class| group_class.instructor.id }
      column("age_group_id") { |group_class| group_class.age_group.id }
      column :fee
      column :fee_type_id
      column :lesson_count
      column :remarks
      column("Level") { |group_class| group_class.level.id }
    end

    index do
      selectable_column
      id_column
      column :day
      column :time, :sortable => :time do |obj|
        obj.time.localtime.strftime("%I:%M %p") if obj.time
      end
      column :instructor
      column :venue
      column :duration
      column :fee
      column "Fee Type" do |group_class|
      if group_class.fee_type_id.present?
        class_type = FeeType.find(group_class.fee_type_id).name
      end
    end
      column :level
      column :age_group
      column :lesson_count
      column :remarks
      actions
    end

    form do |f|
      f.inputs "Group class Details" do
        f.input :day, as: :select, collection: week_days.zip(0..6)
        f.input :time
        f.input :instructor
        f.input :venue
        f.input :age_group
        f.input :level
        f.input :duration
        f.input :fee
        f.input :fee_type_id, :label => "Fee Type", as: :select, collection: FeeType.all.collect{ |u| [u.name, u.id]}
        f.input :lesson_count
        f.input :remarks
      end
      f.actions
    end

    show do |group_class|
      attributes_table do
        row :id
        row :day
        row :time
        row :instructor
        row :venue
        row :age_group
        row :level
        row :duration
        row :fee
        row "Fee Type" do |group_class|
        if group_class.fee_type_id.present?
          class_type = FeeType.find(group_class.fee_type_id).name
        end
      end
        row :lesson_count
        row :remarks
        row :created_at
        row :updated_at
      end
    end

end
