# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every :day, at: "07:00pm" do
  runner "Instructor.periodically_send_student_detail", :output => 'cron.log'
end

# every 2.minutes do
#   runner "Instructor.periodically_send_student_detail", :output => 'cron.log'
# end

# Learn more: http://github.com/javan/whenever
