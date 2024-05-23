class ApplicationController < ActionController::API
  include JsonWebToken
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate
    header = request.headers['Authorization']
    header = header.split.last if header
    decoded = jwt_decode(header)
    if decoded
      @current_user = User.find_by(supabase_id: decoded[:sub])
      render json: { error: 'Não autorizado' }, status: :unauthorized unless @current_user
    else
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end

  attr_reader :current_user

  def user_not_authorized
    render json: { error: 'Forbidden' }, status: :forbidden
  end

  def pagination_dict(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
