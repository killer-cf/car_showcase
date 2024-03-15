FactoryBot.define do
  factory :car do
    sequence(:name) { |n| "Car#{n}" }
    year { 2022 }
    status { 0 }
    brand { nil }
    model { nil }
  end
end
