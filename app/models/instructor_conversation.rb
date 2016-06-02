class InstructorConversation < ActiveRecord::Base
  belongs_to :instructor
  has_many :instructor_messages, dependent: :destroy
end
