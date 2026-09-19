require "test_helper"

class SalaryTest < ActiveSupport::TestCase
  test "assign_new closes prior open salary" do
    alice = employees(:alice)
    prior = salaries(:alice_current)
    assert_nil prior.effective_to

    new_salary = Salary.assign_new!(
      employee: alice,
      amount_cents: 13_000_000,
      currency: "USD",
      effective_from: Date.new(2024, 6, 1),
      reason: "Annual raise"
    )

    prior.reload
    assert_equal Date.new(2024, 5, 31), prior.effective_to
    assert_nil new_salary.effective_to
    assert_equal new_salary.id, alice.current_salary.id
  end

  test "assign_new does not overwrite prior row amounts" do
    alice = employees(:alice)
    prior = salaries(:alice_current)
    old_amount = prior.amount_cents

    Salary.assign_new!(
      employee: alice,
      amount_cents: 14_000_000,
      currency: "USD",
      effective_from: Date.new(2025, 1, 1),
      reason: "Market adjustment"
    )

    prior.reload
    assert_equal old_amount, prior.amount_cents
    assert_not_nil prior.effective_to
  end

  test "rejects non-positive amount" do
    s = Salary.new(
      employee: employees(:bob),
      amount_cents: 0,
      currency: "INR",
      effective_from: Date.current
    )
    assert_not s.valid?
  end
end
