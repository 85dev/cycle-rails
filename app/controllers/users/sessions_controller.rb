class Users::SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(_resource, _opts = {})
        if current_user
            render json: {
              message: 'You are logged in.',
              user: current_user
            }, status: :ok
          else
            render json: {
              message: 'No user found.'
            }, status: :unauthorized
          end
    end

    def respond_to_on_destroy
        log_out_success && return if current_user

        log_out_failure
    end

    def log_out_success
        render json: { message: 'You are logged out.'}, status: :ok
    end

    def log_out_failure
        render json: { message: 'Impossible to log out.'}, status: :unauthorized
    end
end