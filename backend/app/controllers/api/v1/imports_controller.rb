require "csv"

module Api
  module V1
    class ImportsController < BaseController
      def employees
        file = params[:file]
        unless file.respond_to?(:read)
          return render json: { error: "CSV file required (param: file)" }, status: :bad_request
        end

        created = 0
        updated = 0
        errors = []

        CSV.parse(file.read, headers: true) do |row|
          attrs = {
            employee_code: row["employee_code"] || row["Employee Code"],
            first_name: row["first_name"] || row["First Name"],
            last_name: row["last_name"] || row["Last Name"],
            email: row["email"] || row["Email"],
            country: row["country"] || row["Country"],
            department: row["department"] || row["Department"],
            hire_date: row["hire_date"] || row["Hire Date"],
            status: (row["status"] || row["Status"] || "active").to_s.downcase
          }

          employee = Employee.find_or_initialize_by(employee_code: attrs[:employee_code])
          is_new = employee.new_record?
          employee.assign_attributes(attrs)

          if employee.save
            is_new ? created += 1 : updated += 1

            amount = row["salary_amount_cents"] || row["amount_cents"]
            currency = row["currency"] || Salary::COUNTRY_CURRENCY[employee.country]
            if amount.present? && currency.present?
              begin
                Salary.assign_new!(
                  employee: employee,
                  amount_cents: amount.to_i,
                  currency: currency,
                  effective_from: row["salary_effective_from"].presence || employee.hire_date || Date.current,
                  reason: row["salary_reason"].presence || "CSV import"
                )
              rescue ActiveRecord::RecordInvalid => e
                errors << { employee_code: attrs[:employee_code], errors: e.record.errors.full_messages }
              end
            end
          else
            errors << { employee_code: attrs[:employee_code], errors: employee.errors.full_messages }
          end
        end

        render json: { created: created, updated: updated, errors: errors }
      end
    end
  end
end
