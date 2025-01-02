class MembersController < ApplicationController
    before_action :set_user_by_id, only: [:reject_access_request, :fetch_access_requests, :fetch_pending_requests, :fetch_validated_companies_accounts, :request_access_to_company]
    before_action :set_company, only: [:reject_access_request, :request_access_to_company, :fetch_users_for_company]
    before_action :set_account, only: [:validate_access_request]

    def fetch_validated_companies_accounts
        validated_accounts = @user.accounts.includes(:company).where(status: 'accepted')
        companies = validated_accounts.map(&:company)
    
        render json: companies, status: :ok
    end

    def fetch_access_requests
      owned_companies = Company.joins(:accounts)
                        .where(accounts: { user_id: @user.id, is_owner: true })
                        .pluck(:id)

      if owned_companies.empty?
        render json: [] and return
      end

      # Fetch all pending requests for these companies
      pending_requests = Account.joins(:user, :company)
          .where(status: 'pending', company_id: owned_companies)
          .select(
            'accounts.id AS account_id,
            accounts.is_owner AS is_owner,
            accounts.status AS request_status,
            companies.name AS company_name,
            users.email AS requester_email,
            accounts.created_at'
          )

      # Format the response
      render json: pending_requests.map { |req| {
        request_status: req.request_status,
        account_id: req.account_id,
        is_owner: req.is_owner,
        company_name: req.company_name,
        requester_email: req.requester_email,
        created_at: req.created_at
      } }
    end

    def fetch_pending_requests
      @accounts = Account.joins(:company)
                         .where(user_id: @user.id, status: 'pending')
                         .select('accounts.*, accounts.is_owner, companies.name AS company_name')
    
      render json: @accounts.map { |account| 
        {
          id: account.id,
          company_name: account.company_name,
          is_owner: account.is_owner,
          created_at: account.created_at,
          updated_at: account.updated_at
        }
      }
    end

    def reject_access_request
      account = Account.find_by(user_id: @user.id, company_id: @company.id)
    
      # Update the status to rejected
      if account.update(status: 'rejected', is_owner: false)
        render json: { message: 'Access request rejected successfully', account: account }, status: :ok
      else
        render json: { error: account.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def fetch_users_for_company
      # Fetch users associated with the company
      users = User.joins(:accounts)
                  .where(accounts: { company_id: @company.id })
                  .select(
                    'users.id AS user_id, 
                     users.email AS user_email, 
                     accounts.status AS account_status, 
                     accounts.is_owner AS is_owner, 
                     accounts.created_at AS account_created_at'
                  )
    
      # Format the response
      render json: users.map { |user| 
        {
          user_id: user.user_id,
          user_email: user.user_email,
          account_status: user.account_status,
          is_owner: user.is_owner,
          account_created_at: user.account_created_at
        }
      }
    end

    def request_access_to_company
        existing_account = Account.find_by(user: @user, company: @company)
        if existing_account
          render json: { error: "Access request already exists." }, status: :unprocessable_entity
          return
        end

        requested_owner_rights = params[:requested_owner_rights] == 'true'
  
        Account.create!(
          user: @user,
          company: @company,
          requested_owner_rights: requested_owner_rights,
          is_owner: false,
          status: 'pending'
        )
    
        render json: { success: "Access request sent." }, status: :created
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    def validate_access_request
        owner_account = Account.find_by(user_id: params[:user_id], company_id: @account.company_id, is_owner: true)

        if owner_account.nil?
          render json: { error: 'You are not authorized to validate this request' }, status: :unauthorized
          return
        end

        ActiveRecord::Base.transaction do
          @account.update!(
            status: 'accepted',
            is_owner: @account.requested_owner_rights # Grant owner rights if requested
          )
        end

        render json: { message: 'Request accepted successfully', account: @account }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_account
      account = Account.find_by(user_id: params[:user_id], company_id: params[:company_id])
      
      if account
          render json: {
              status: account.status,
              is_owner: account.is_owner
          }, status: :ok
      else
          render json: { error: 'Account not found' }, status: :not_found
      end
    end

    def show 
        user = get_user_from_token
        render json: {
            message: 'Successfully logged in.',
            user: user
        }
    end

    private

    def set_user_by_id
        @user = User.find_by(id: params[:user_id])
    end

    def set_account
      @account = Account.find_by(id: params[:account_id])
    end

    def set_company
        @company = Company.find_by(id: params[:company_id])
    end

    def get_user_from_token
        jwt_payload = 
        JWT.decode(request.headers['Authorization'].split(' ')[1],
        Rails.application.credentials.devise[:jwt_secret_key]).first

        user_id = jwt_payload['sub']
        user = User.find(user_id.to_s)
    end
end