require "test_helper"

class Api::V1::StatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "password123" }, as: :json
  end

  test "overview with fixture set" do
    get api_v1_stats_overview_url, headers: { "Accept" => "application/json" }
    assert_response :success
    body = JSON.parse(response.body)

    # alice + bob active; carol inactive
    assert_equal 2, body["headcount"]
    assert body["total_payroll"].key?("USD")
    assert body["total_payroll"].key?("INR")
    assert_equal 1, body["by_country"]["US"]
    assert_equal 1, body["by_country"]["IN"]
    assert_equal 1, body["by_department"]["Engineering"]
    assert body["salary_bands"].is_a?(Hash)
  end
end
