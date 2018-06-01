FactoryBot.define do
  factory :membership do
    association :project
    association :user

    trait :with_1_join_member do
      after(:create) { |project| create_list(:membership, 1, project: project, join: true) }
    end
  end
end
