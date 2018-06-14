FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "カード#{n}" }
    due_date Date.tomorrow
    association :assignee
    association :column
    project { column.project }

    after(:build) { |card| card.operator = card.project.user }

    trait :invalid do
      name nil
    end
  end
end
