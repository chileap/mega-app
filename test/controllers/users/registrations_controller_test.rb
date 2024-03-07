require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include InvisibleCaptcha

  setup do
    OmniAuth.config.add_mock(:google_oauth2)
    @user_params = {user:
                        {name: "Test User",
                         email: "user@test.com",
                         password: "TestPassword",
                         terms_of_service: "1"}}

    # With this feature enabled, we also need to submit an workspace
    if Jumpstart.config.register_with_workspace?
      @user_params[:user][:owned_workspaces_attributes] = [{name: "Test Account"}]
    end
  end

  class BasicRegistrationTest < Users::RegistrationsControllerTest
    test "successfully registration form render" do
      get new_user_registration_path
      assert_response :success
      assert response.body.include?("user[name]")
      assert response.body.include?("user[email]")
      assert response.body.include?("user[password]")
      assert response.body.include?(InvisibleCaptcha.sentence_for_humans)
    end

    test "successful user registration" do
      assert_difference "User.count" do
        post user_registration_url, params: @user_params
      end
    end

    test "failed user registration" do
      assert_no_difference "User.count" do
        post user_registration_url, params: {}
      end
    end
  end

  class InvibleCaptchaTest < Users::RegistrationsControllerTest
    test "honeypot is not filled and user creation succeeds" do
      assert_difference "User.count" do
        post user_registration_url, params: @user_params.merge(honeypotx: "")
      end
    end

    test "honeypot is filled and user creation fails" do
      assert_no_difference "User.count" do
        post user_registration_url, params: @user_params.merge(honeypotx: "spam")
      end
    end
  end

  class RegisterWithAccountTest < Users::RegistrationsControllerTest
    test "doesn't prompt for workspace details on sign up if disabled" do
      Jumpstart.config.stub(:register_with_workspace?, false) do
        get new_user_registration_path
        assert_no_match I18n.t("helpers.label.workspace.name"), response.body
      end
    end

    test "prompts for workspace details on sign up if enabled" do
      Jumpstart.config.stub(:register_with_workspace?, true) do
        get new_user_registration_path
        assert_select "label", text: I18n.t("helpers.label.workspace.name")
      end
    end
  end
end
