class UserMailer < ApplicationMailer
    def send_reset_code
        @user = params[:user]
        @reset_code = params[:reset_code]

        mail(
            to: @user.email,
            subject: "Cycle Application - Votre code d'accès"
        )
    end
end