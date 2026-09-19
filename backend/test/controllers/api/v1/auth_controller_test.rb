require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "login success" do
    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "password123" }, as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "hr@acme.com", body["user"]["email"]
  end

  test "login failure" do
    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "nope" }, as: :json
    assert_response :unauthorized
  end

  test "me requires session" do
    get api_v1_auth_me_url, headers: { "Accept" => "application/json" }
    assert_response :unauthorized

    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "password123" }, as: :json
    get api_v1_auth_me_url, headers: { "Accept" => "application/json" }
    assert_response :success
  end

  test "logout clears session" do
    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "password123" }, as: :json
    delete api_v1_auth_logout_url, headers: { "Accept" => "application/json" }
    assert_response :no_content
    get api_v1_auth_me_url, headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end
end
