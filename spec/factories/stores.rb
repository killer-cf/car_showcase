FactoryBot.define do
  factory :store do
    name { 'MyString' }
    tax_id { CPF.generate }
    phone { 'MyString' }
    user
  end
end
