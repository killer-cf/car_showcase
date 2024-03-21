FactoryBot.define do
  factory :employee do
    role { :admin }
    store { nil }
    user { nil }
  end
end
