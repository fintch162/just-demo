class AddAwardTestIdToInstructorMessage < ActiveRecord::Migration
  def change
    add_reference :instructor_messages, :award_test, index: true
  end
end
