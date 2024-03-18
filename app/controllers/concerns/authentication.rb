module Authentication
  include Keycloak::Authentication

  def authenticate
    render json: { error: 'Unauthorized' }, status: :unauthorized if keycloak_authenticate[0] == 401
  end

  def require_admin!
    authorize(roles: ['ADMIN'])
  end

  private

  def authorize(roles:)
    render json: { message: 'Forbidden' }, status: :forbidden unless (current_user_roles & roles).any?
  end

  def current_user_roles
    Keycloak::Helper.current_user_roles(request.env)
  end
end
