module Api
  module V1
    class ProfileController < BaseController
      def me
        render json: {
          id: current_user.id,
          email_address: current_user.email_address,
          has_api_token: current_user.api_token.present?
        }
      end
    end
  end
end
