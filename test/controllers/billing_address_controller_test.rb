require "test_helper"

class BillingAddressControllerTest < ActionDispatch::IntegrationTest
  test "should get new if authenticated" do
    Jumpstart.config.stub(:payments_enabled?, true) do
      @user_two = users(:two)
      sign_in @user_two

      get new_billing_address_url

      assert_response :success
    end
  end

  test "should get edit if authenticated" do
    Jumpstart.config.stub(:payments_enabled?, true) do
      Jumpstart::Multitenancy.stub :selected, [] do
        @user_one = users(:one)
        @user_one_workspace = workspaces(:one)

        sign_in @user_one
        switch_workspace(@user_one_workspace)

        get edit_billing_address_url
        assert_response :success
      end
    end
  end
end
