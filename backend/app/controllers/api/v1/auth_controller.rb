module Api
  module V1
    class AuthController < ApplicationController
      def login
        user = User.find_by(email: params[:email].to_s.strip.downcase)
        if user&.authenticate(params[:password].to_s)
          session[:user_id] = user.id
          render json: { user: user_json(user) }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def logout
        reset_session
        head :no_content
      end

      def me
        if current_user
          render json: { user: user_json(current_user) }
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      private

      def user_json(user)
        { id: user.id, email: user.email, role: user.role }
      end
    end
  end
end
