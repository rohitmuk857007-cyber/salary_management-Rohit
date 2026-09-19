require "test_helper"

class Api::V1::EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post api_v1_auth_login_url, params: { email: "hr@acme.com", password: "password123" }, as: :json
  end

  test "index filters and paginates" do
    get api_v1_employees_url, params: { q: "Alice", status: "active" },
        headers: { "Accept" => "application/json" }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["employees"].length
    assert_equal "ACM000001", body["employees"][0]["employee_code"]
  end

  test "show includes salaries" do
    get api_v1_employee_url(employees(:alice)), headers: { "Accept" => "application/json" }
    assert_response :success
    body = JSON.parse(response.body)
    assert body["salaries"].length >= 2
  end
end
