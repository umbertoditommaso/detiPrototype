require 'test_helper'

class TelemetriesControllerTest < ActionController::TestCase
  setup do
    @telemetry = telemetries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:telemetries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create telemetry" do
    assert_difference('Telemetry.count') do
      post :create, telemetry: {  }
    end

    assert_redirected_to telemetry_path(assigns(:telemetry))
  end

  test "should show telemetry" do
    get :show, id: @telemetry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @telemetry
    assert_response :success
  end

  test "should update telemetry" do
    put :update, id: @telemetry, telemetry: {  }
    assert_redirected_to telemetry_path(assigns(:telemetry))
  end

  test "should destroy telemetry" do
    assert_difference('Telemetry.count', -1) do
      delete :destroy, id: @telemetry
    end

    assert_redirected_to telemetries_path
  end
end
