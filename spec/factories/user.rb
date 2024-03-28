FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    tax_id { CPF.generate }
    keycloak_id { SecureRandom.uuid }
  end
end
