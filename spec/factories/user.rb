FactoryBot.define do
  factory :user do
    name { 'Kilder' }
    tax_id { CPF.generate }
  end
end
