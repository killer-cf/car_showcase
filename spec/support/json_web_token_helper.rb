module JsonWebTokenHelper
  def generate_jwt(user)
    payload = { sub: user.supabase_id }
    JWT.encode(payload, Rails.application.credentials.dig(:test, :supabase, :jwt_secret))
  end
end
