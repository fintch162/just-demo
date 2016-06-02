require 'test_helper'

class ApiSettingsControllerTest < ActionController::TestCase
  setup do
    @api_setting = api_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:api_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create api_setting" do
    assert_difference('ApiSetting.count') do
      post :create, api_setting: { fb_api_url: @api_setting.fb_api_url, fb_authentication_token: @api_setting.fb_authentication_token, telerivet_api_key: @api_setting.telerivet_api_key, telerivet_phone_id: @api_setting.telerivet_phone_id, telerivet_project_id: @api_setting.telerivet_project_id }
    end

    assert_redirected_to api_setting_path(assigns(:api_setting))
  end

  test "should show api_setting" do
    get :show, id: @api_setting
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @api_setting
    assert_response :success
  end

  test "should update api_setting" do
    patch :update, id: @api_setting, api_setting: { fb_api_url: @api_setting.fb_api_url, fb_authentication_token: @api_setting.fb_authentication_token, telerivet_api_key: @api_setting.telerivet_api_key, telerivet_phone_id: @api_setting.telerivet_phone_id, telerivet_project_id: @api_setting.telerivet_project_id }
    assert_redirected_to api_setting_path(assigns(:api_setting))
  end

  test "should destroy api_setting" do
    assert_difference('ApiSetting.count', -1) do
      delete :destroy, id: @api_setting
    end

    assert_redirected_to api_settings_path
  end
end
