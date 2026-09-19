module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy]

      def index
        scope = Employee.search(params[:q])
                        .by_country(params[:country])
                        .by_department(params[:department])
                        .by_status(params[:status])
                        .order(:employee_code)

        page = [params.fetch(:page, 1).to_i, 1].max
        per_page = [[params.fetch(:per_page, 25).to_i, 1].max, 100].min
        total = scope.count
        employees = scope.offset((page - 1) * per_page).limit(per_page)

        render json: {
          employees: employees.map { |e| employee_json(e) },
          meta: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total.to_f / per_page).ceil
          }
        }
      end

      def show
        render json: employee_json(@employee, include_salaries: true)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee_json(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: employee_json(@employee)
        else
          render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @employee.destroy!
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Employee not found" }, status: :not_found
      end

      def employee_params
        params.require(:employee).permit(
          :employee_code, :first_name, :last_name, :email,
          :country, :department, :hire_date, :status
        )
      end

      def employee_json(employee, include_salaries: false)
        current = employee.current_salary
        data = {
          id: employee.id,
          employee_code: employee.employee_code,
          first_name: employee.first_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          email: employee.email,
          country: employee.country,
          department: employee.department,
          hire_date: employee.hire_date,
          status: employee.status,
          current_salary: current && {
            id: current.id,
            amount_cents: current.amount_cents,
            currency: current.currency,
            effective_from: current.effective_from,
            reason: current.reason
          }
        }
        if include_salaries
          data[:salaries] = employee.salaries.order(effective_from: :desc, id: :desc).map { |s| salary_json(s) }
        end
        data
      end

      def salary_json(salary)
        {
          id: salary.id,
          amount_cents: salary.amount_cents,
          currency: salary.currency,
          effective_from: salary.effective_from,
          effective_to: salary.effective_to,
          reason: salary.reason,
          current: salary.effective_to.nil?
        }
      end
    end
  end
end
