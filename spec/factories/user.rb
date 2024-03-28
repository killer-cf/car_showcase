FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:email) { |n| "email.user#{n}@gmail.com" }
    tax_id { CPF.generate }
    keycloak_id { SecureRandom.uuid }
  end
end
