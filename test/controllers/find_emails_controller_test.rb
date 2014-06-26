require 'test_helper'

class FindEmailsControllerTest < ActionController::TestCase
  test "should get add_names" do
    get :add_names
    assert_response :success
  end

end
