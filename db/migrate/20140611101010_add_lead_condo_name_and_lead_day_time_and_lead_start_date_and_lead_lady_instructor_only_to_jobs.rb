class AddLeadCondoNameAndLeadDayTimeAndLeadStartDateAndLeadLadyInstructorOnlyToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :lead_condo_name, :string
    add_column :jobs, :lead_day_time, :text
    add_column :jobs, :lead_starting_on, :date
    add_column :jobs, :lead_lady_instructor_only, :boolean
  end
end
