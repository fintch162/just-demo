class OldInstructor < ActiveRecord::Base
  self.table_name = "instructors"
  has_many :group_classes, foreign_key: :instructor_id
end

namespace :migrate_data do
  desc 'Migrate old instructors to new instructors with group_classe'
  task instructors: :environment do
    default_pass = "password"
    OldInstructor.includes(:group_classes).all.each do |instructor|
      new_instructor = Instructor.create(password: default_pass, password_confirmation: default_pass, email: "#{instructor.id}@instructor.com", name: instructor.name, mobile: instructor.mobile)
      instructor.group_classes.update_all(instructor_id: new_instructor) if new_instructor.persisted?
    end
  end
end