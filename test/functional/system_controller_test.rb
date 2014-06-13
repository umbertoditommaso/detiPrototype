require 'test_helper'

class SystemControllerTest < ActionController::TestCase
  test "should get mv" do
    get :mv
    assert_response :success
  end

  test "should get cp" do
    get :cp
    assert_response :success
  end

end
