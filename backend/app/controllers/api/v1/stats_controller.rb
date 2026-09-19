module Api
  module V1
    class StatsController < BaseController
      def overview
        active = Employee.where(status: "active")
        headcount = active.count

        current_salaries = Salary.current.joins(:employee).where(employees: { status: "active" })

        # Total payroll grouped by currency (cents)
        by_currency = current_salaries.group(:currency).sum(:amount_cents)

        by_country = active.group(:country).count
        by_department = active.group(:department).count

        # Approximate bands in USD-equivalent is out of scope; band by amount_cents within each currency
        # Provide global bands using amount_cents as-is for demo simplicity, plus per-currency breakdown.
        bands = {
          "under_50k" => 0,
          "50k_100k" => 0,
          "100k_150k" => 0,
          "150k_plus" => 0
        }
        current_salaries.pluck(:amount_cents).each do |cents|
          # Treat as major units * 100 for banding (e.g. USD cents)
          amount = cents / 100.0
          case amount
          when ...50_000 then bands["under_50k"] += 1
          when 50_000...100_000 then bands["50k_100k"] += 1
          when 100_000...150_000 then bands["100k_150k"] += 1
          else bands["150k_plus"] += 1
          end
        end

        render json: {
          headcount: headcount,
          total_payroll: by_currency.transform_values(&:to_i),
          by_country: by_country,
          by_department: by_department,
          salary_bands: bands
        }
      end
    end
  end
end
