FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "カード#{n}" }
    due_date Date.tomorrow
    association :assignee
    association :column
    project { column.project }

    after(:build) { |card| card.operator = FactoryBot.create(:user) }

    trait :name_40 do
      name '1234567890123456789012345678901234567890'
    end

    trait :name_41 do
      name '12345678901234567890123456789012345678901'
    end

    trait :invalid do
      name nil
    end
  end
end
