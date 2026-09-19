module Api
  module V1
    class SalariesController < BaseController
      before_action :set_employee

      def index
        salaries = @employee.salaries.order(effective_from: :desc, id: :desc)
        render json: { salaries: salaries.map { |s| salary_json(s) } }
      end

      def create
        salary = Salary.assign_new!(
          employee: @employee,
          amount_cents: salary_params[:amount_cents],
          currency: salary_params[:currency],
          effective_from: salary_params[:effective_from],
          reason: salary_params[:reason]
        )
        render json: salary_json(salary), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Employee not found" }, status: :not_found
      end

      def salary_params
        params.require(:salary).permit(:amount_cents, :currency, :effective_from, :reason)
      end

      def salary_json(salary)
        {
          id: salary.id,
          employee_id: salary.employee_id,
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
