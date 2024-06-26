FactoryBot.define do
  factory :car do
    sequence(:name) { |n| "Car#{n}" }
    year { 2022 }
    brand { nil }
    model { nil }
    price { 100_000.00 }
    km { 23.500 }
    used { true }
    store
    after(:build) do |car|
      car.images.attach(io: Rails.root.join('spec/fixtures/files/car.png').open('rb'),
                        filename: 'car.png', content_type: 'image/png')
    end
  end
end
