require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with password" do
    user = users(:hr)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end

  test "requires unique email" do
    u = User.new(email: "hr@acme.com", password: "password123", role: "hr")
    assert_not u.valid?
  end
end
