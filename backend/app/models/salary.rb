class Salary < ApplicationRecord
  CURRENCIES = %w[USD INR GBP EUR SGD AUD].freeze
  COUNTRY_CURRENCY = {
    "US" => "USD", "IN" => "INR", "GB" => "GBP",
    "DE" => "EUR", "SG" => "SGD", "AU" => "AUD"
  }.freeze

  belongs_to :employee

  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :effective_from, presence: true
  validate :effective_to_after_from

  scope :current, -> { where(effective_to: nil) }

  # Create a new salary row and close any prior open (effective_to nil) salary
  # in the same transaction. Never overwrites existing rows.
  def self.assign_new!(employee:, amount_cents:, currency:, effective_from:, reason: nil)
    transaction do
      open_salaries = employee.salaries.where(effective_to: nil).lock
      open_salaries.find_each do |prior|
        close_on = [effective_from.to_date - 1.day, prior.effective_from].max
        prior.update!(effective_to: close_on)
      end

      create!(
        employee: employee,
        amount_cents: amount_cents,
        currency: currency,
        effective_from: effective_from,
        effective_to: nil,
        reason: reason
      )
    end
  end

  private

  def effective_to_after_from
    return if effective_to.blank? || effective_from.blank?
    if effective_to < effective_from
      errors.add(:effective_to, "must be on or after effective_from")
    end
  end
end
