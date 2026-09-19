require "csv"

module Api
  module V1
    class ExportsController < BaseController
      def employees
        csv = CSV.generate(headers: true) do |out|
          out << %w[
            employee_code first_name last_name email country department
            hire_date status amount_cents currency salary_effective_from
          ]
          Employee.includes(:salaries).order(:employee_code).find_each do |emp|
            sal = emp.current_salary
            out << [
              emp.employee_code,
              emp.first_name,
              emp.last_name,
              emp.email,
              emp.country,
              emp.department,
              emp.hire_date,
              emp.status,
              sal&.amount_cents,
              sal&.currency,
              sal&.effective_from
            ]
          end
        end

        send_data csv,
                  filename: "employees-#{Date.current}.csv",
                  type: "text/csv",
                  disposition: "attachment"
      end
    end
  end
end
