class UserMailer < ApplicationMailer
    def send_access_code
        @user = params[:user]
        @access_code = params[:access_code]

        mail(to: @user.email, subject: "Votre code d'accès")
    end

    def send_verification_code
        @email = params[:email]
        @access_code = params[:access_code]
    
        mail(to: @email, subject: 'Vérification de votre adresse email')
    end

    def send_request_authorization
        @guest = params[:user]
        @owner = params[:owner]

        mail(to: @guest.email, subject: 'Un accès entreprise vous a été attribué')
    end
end