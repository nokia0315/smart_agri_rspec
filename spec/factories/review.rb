FactoryBot.define do
  factory :review do
    title { Faker::Lorem.characters(number: 20) }
    explanation { Faker::Lorem.characters(number: 100) }
    rate { Faker::Lorem.characters(number: 20) }#メンターに質問
  end
end