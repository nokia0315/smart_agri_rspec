FactoryBot.define do
  factory :genre do
    name { Faker::Lorem.characters(number: 20) }
  end
end