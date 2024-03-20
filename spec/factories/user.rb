FactoryBot.define do
  factory :user do
    name { 'Kilder' }
    tax_id { CPF.generate }
    keycloak_id { SecureRandom.uuid }
  end
end
