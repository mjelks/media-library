module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_with_token!

      private

      def authenticate_with_token!
        token = extract_token
        return render_unauthorized unless token.present?

        @current_user = User.find_by(api_token: token)
        render_unauthorized unless @current_user
      end

      def extract_token
        # Support both Bearer token and X-Api-Token header
        if request.headers["Authorization"].present?
          request.headers["Authorization"].split(" ").last
        else
          request.headers["X-Api-Token"]
        end
      end

      def render_unauthorized
        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def current_user
        @current_user
      end
    end
  end
end
