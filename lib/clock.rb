# require boot & environment for a Rails app
require_relative "../config/boot"
require_relative "../config/environment"

require 'clockwork'

module Clockwork

  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  # Kick off a bunch of jobs early in the morning

  every 1.day, 'send student detail', at: "00:01" do
    ::Instructor.periodically_send_student_detail
  end

  every 10.seconds, 'send student detail' do
    ::Instructor.periodically_send_student_detail
  end
end