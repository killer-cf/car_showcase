class ApplicationController < ActionController::API
  include Keycloak::Authentication

  def authenticate
    render json: { error: 'Unauthorized' }, status: :unauthorized if keycloak_authenticate[0] == 401
  end
end
