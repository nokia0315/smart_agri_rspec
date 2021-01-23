FactoryBot.define do
  factory :job_offer do
    title { Faker::Lorem.characters(number: 20) }
    explanation { Faker::Lorem.characters(number: 100) }
    reward { Faker::Lorem.characters(number: 20) }
  end
end