class Employee < ApplicationRecord
  COUNTRIES = %w[US IN GB DE SG AU].freeze
  DEPARTMENTS = %w[Engineering Sales HR Finance Operations Support].freeze
  STATUSES = %w[active inactive].freeze

  has_many :salaries, dependent: :destroy

  validates :employee_code, presence: true, uniqueness: true
  validates :first_name, :last_name, :email, :hire_date, presence: true
  validates :country, presence: true, inclusion: { in: COUNTRIES }
  validates :department, presence: true, inclusion: { in: DEPARTMENTS }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :search, ->(q) {
    return all if q.blank?
    term = "%#{q.to_s.strip}%"
    where(
      "employee_code LIKE :t OR first_name LIKE :t OR last_name LIKE :t OR email LIKE :t",
      t: term
    )
  }
  scope :by_country, ->(c) { c.present? ? where(country: c) : all }
  scope :by_department, ->(d) { d.present? ? where(department: d) : all }
  scope :by_status, ->(s) { s.present? ? where(status: s) : all }

  def current_salary
    salaries.where(effective_to: nil).order(effective_from: :desc, id: :desc).first ||
      salaries.order(effective_from: :desc, id: :desc).first
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
