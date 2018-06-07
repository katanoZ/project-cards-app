FactoryBot.define do
  factory :column do
    sequence(:name) { |n| "カラム#{n}" }
    association :project

    after(:build) { |column| column.operator = column.project.user }

    trait :invalid do
      name nil
    end
  end
end
