FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "カード#{n}" }
    due_date Date.tomorrow
    association :assignee
    association :column
    project { column.project }

    after(:build) { |card| card.operator = FactoryBot.create(:user) }

    trait :name_40 do
      name Faker::Lorem.characters(40)
    end

    trait :name_41 do
      name Faker::Lorem.characters(41)
    end

    trait :invalid do
      name nil
    end
  end
end
