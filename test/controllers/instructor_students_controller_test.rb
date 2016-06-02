require 'test_helper'

class InstructorStudentsControllerTest < ActionController::TestCase
  setup do
    @instructor_student = instructor_students(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instructor_students)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create instructor_student" do
    assert_difference('InstructorStudent.count') do
      post :create, instructor_student: { age: @instructor_student.age, contact: @instructor_student.contact, date_of_birth: @instructor_student.date_of_birth, gender: @instructor_student.gender, job_id: @instructor_student.job_id, student_name: @instructor_student.student_name }
    end

    assert_redirected_to instructor_student_path(assigns(:instructor_student))
  end

  test "should show instructor_student" do
    get :show, id: @instructor_student
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @instructor_student
    assert_response :success
  end

  test "should update instructor_student" do
    patch :update, id: @instructor_student, instructor_student: { age: @instructor_student.age, contact: @instructor_student.contact, date_of_birth: @instructor_student.date_of_birth, gender: @instructor_student.gender, job_id: @instructor_student.job_id, student_name: @instructor_student.student_name }
    assert_redirected_to instructor_student_path(assigns(:instructor_student))
  end

  test "should destroy instructor_student" do
    assert_difference('InstructorStudent.count', -1) do
      delete :destroy, id: @instructor_student
    end

    assert_redirected_to instructor_students_path
  end
end
