Keycloak.configure do |config|
  config.server_url = Rails.application.credentials.dig(Rails.env.to_sym, :keycloak, :server_url)
  config.realm_id   = Rails.application.credentials.dig(Rails.env.to_sym, :keycloak, :realm_id)
  config.logger     = Rails.logger
  config.opt_in     = true
end
