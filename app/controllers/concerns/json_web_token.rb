module JsonWebToken
  extend ActiveSupport::Concern

  def jwt_decode(token)
    jwt_secret = Rails.application.credentials.dig(Rails.env.to_sym, :supabase, :jwt_secret)
    body = JWT.decode(token, jwt_secret)[0]
    ActiveSupport::HashWithIndifferentAccess.new body
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
    Rails.logger.error e.message
    nil
  end
end
