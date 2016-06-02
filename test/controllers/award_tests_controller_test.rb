require 'test_helper'

class AwardTestsControllerTest < ActionController::TestCase
  setup do
    @award_test = award_tests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:award_tests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create award_test" do
    assert_difference('AwardTest.count') do
      post :create, award_test: { assessor: @award_test.assessor, award_id: @award_test.award_id, test_date: @award_test.test_date, test_time: @award_test.test_time, venue_id: @award_test.venue_id }
    end

    assert_redirected_to award_test_path(assigns(:award_test))
  end

  test "should show award_test" do
    get :show, id: @award_test
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @award_test
    assert_response :success
  end

  test "should update award_test" do
    patch :update, id: @award_test, award_test: { assessor: @award_test.assessor, award_id: @award_test.award_id, test_date: @award_test.test_date, test_time: @award_test.test_time, venue_id: @award_test.venue_id }
    assert_redirected_to award_test_path(assigns(:award_test))
  end

  test "should destroy award_test" do
    assert_difference('AwardTest.count', -1) do
      delete :destroy, id: @award_test
    end

    assert_redirected_to award_tests_path
  end
end
