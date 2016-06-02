attributes :id, :duration, :lesson_count, :remarks
node(:fee){|item| number_to_currency(item.fee) }
node(:level_id){ |item| item.level.try(:title) }
node(:instructor_id){ |item| item.instructor.try(:name) }
node(:venue_id){ |item| item.venue.try(:name) }
node(:age_group_id){ |item| item.age_group.try(:title) }
node(:class_type_id){ |item| item.class_type.try(:title) }
node(:day){|item| week_days[item.day] if item.day  }
node(:time){|item| item.time_formatted }
node(:edit_link){|item| edit_manage_group_class_path(item)}
node(:view_link){|item| manage_group_class_path(item)}
node(:delete_link){ |item| url_for([:manage, item]) }
