class InstructorStudentAward < ActiveRecord::Base
	belongs_to :award
	belongs_to :instructor_student
	belongs_to :award_test

  scope :achieved_award, -> { where("award_progress IN (?)", ["achieved", "training_for", "ready_for"]) }
  scope :award_test_ids_by_student, ->(student_name) { where('instructor_student_id IN (?)', InstructorStudent.ids_by_name(student_name)).pluck('award_test_id') }
  scope :by_student_and_award_test, ->(student_id,award_test_id) { find_by(award_test_id: award_test_id,instructor_student_id: student_id).id }
end