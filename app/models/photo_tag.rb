class PhotoTag < ActiveRecord::Base
  belongs_to :instructor_student
  belongs_to :instructor
  belongs_to :phototaggable, :polymorphic => true
  scope :find_photo, ->(st_id,ins_id,photo_id,type) { find_by(instructor_student_id: st_id,instructor_id: ins_id,phototaggable_id: photo_id,phototaggable_type: type) }
end
