FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "プロジェクト#{n}" }
    summary '社内用アプリを開発するプロジェクトです'
    association :user

    trait :name_140 do
      name Faker::Lorem.characters(140)
    end

    trait :name_141 do
      name Faker::Lorem.characters(141)
    end

    trait :summary_300 do
      summary Faker::Lorem.characters(300)

    end

    trait :summary_301 do
      summary Faker::Lorem.characters(301)
    end

    trait :with_5_invite_members do
      after(:create) { |project| create_list(:membership, 5, project: project) }
    end

    trait :with_1_join_member do
      after(:create) { |project| create_list(:membership, 1, project: project, join: true) }
    end

    trait :with_5_join_members_and_2_invite_members do
      after(:create) { |project| create_list(:membership, 5, project: project, join: true) }
      after(:create) { |project| create_list(:membership, 2, project: project, join: false) }
    end
  end
end
