FactoryBot.define do
  factory :car do
    sequence(:name) { |n| "Car#{n}" }
    year { 2022 }
    status { 0 }
    brand { nil }
    model { nil }
    store
    after(:build) do |car|
      car.images.attach(io: Rails.root.join('spec/fixtures/files/car.png').open('rb'),
                        filename: 'car.png', content_type: 'image/png')
    end
  end
end
