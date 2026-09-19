require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert employees(:alice).valid?
  end

  test "requires unique employee_code" do
    dup = employees(:alice).dup
    dup.email = "other@acme.example"
    assert_not dup.valid?
    assert_includes dup.errors[:employee_code], "has already been taken"
  end

  test "validates country inclusion" do
    e = employees(:alice)
    e.country = "ZZ"
    assert_not e.valid?
  end

  test "validates department inclusion" do
    e = employees(:alice)
    e.department = "Marketing"
    assert_not e.valid?
  end

  test "validates status inclusion" do
    e = employees(:alice)
    e.status = "pending"
    assert_not e.valid?
  end

  test "requires presence of core fields" do
    e = Employee.new
    assert_not e.valid?
    %i[employee_code first_name last_name email country department hire_date].each do |attr|
      assert_includes e.errors[attr], "can't be blank"
    end
  end
end
