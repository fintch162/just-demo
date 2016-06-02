require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @job = jobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job" do
    assert_difference('Job.count') do
      post :create, job: { age_group: @job.age_group, class_level: @job.class_level, class_time: @job.class_time, class_type: @job.class_type, completed_by: @job.completed_by, coordinator_notes: @job.coordinator_notes, customer_contact: @job.customer_contact, customer_name: @job.customer_name, day_of_week: @job.day_of_week, fee_structure: @job.fee_structure, fee_total: @job.fee_total, first_attendance: @job.first_attendance, free_goggles: @job.free_goggles, goggles_status: @job.goggles_status, instructor_id: @job.instructor_id, job_ref: @job.job_ref, job_status: @job.job_status, lady_instructor: @job.lady_instructor, lead_address: @job.lead_address, lead_contact: @job.lead_contact, lead_email: @job.lead_email, lead_info: @job.lead_info, lead_name: @job.lead_name, lesson_count: @job.lesson_count, lock_date: @job.lock_date, message_to_customer: @job.message_to_customer, message_to_instructor: @job.message_to_instructor, par_pax: @job.par_pax, post_date: @job.post_date, preferred_time: @job.preferred_time, referral: @job.referral, show_names: @job.show_names, start_date: @job.start_date, venue: @job.venue, venue_id: @job.venue_id }
    end

    assert_redirected_to job_path(assigns(:job))
  end

  test "should show job" do
    get :show, id: @job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job
    assert_response :success
  end

  test "should update job" do
    patch :update, id: @job, job: { age_group: @job.age_group, class_level: @job.class_level, class_time: @job.class_time, class_type: @job.class_type, completed_by: @job.completed_by, coordinator_notes: @job.coordinator_notes, customer_contact: @job.customer_contact, customer_name: @job.customer_name, day_of_week: @job.day_of_week, fee_structure: @job.fee_structure, fee_total: @job.fee_total, first_attendance: @job.first_attendance, free_goggles: @job.free_goggles, goggles_status: @job.goggles_status, instructor_id: @job.instructor_id, job_ref: @job.job_ref, job_status: @job.job_status, lady_instructor: @job.lady_instructor, lead_address: @job.lead_address, lead_contact: @job.lead_contact, lead_email: @job.lead_email, lead_info: @job.lead_info, lead_name: @job.lead_name, lesson_count: @job.lesson_count, lock_date: @job.lock_date, message_to_customer: @job.message_to_customer, message_to_instructor: @job.message_to_instructor, par_pax: @job.par_pax, post_date: @job.post_date, preferred_time: @job.preferred_time, referral: @job.referral, show_names: @job.show_names, start_date: @job.start_date, venue: @job.venue, venue_id: @job.venue_id }
    assert_redirected_to job_path(assigns(:job))
  end

  test "should destroy job" do
    assert_difference('Job.count', -1) do
      delete :destroy, id: @job
    end

    assert_redirected_to jobs_path
  end
end
