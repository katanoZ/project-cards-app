FactoryBot.define do
  factory :column do
    sequence(:name) { |n| "カラム#{n}" }
    association :project

    after(:build) { |column| column.operator = FactoryBot.create(:user) }

    trait :name_40 do
      name Faker::Lorem.characters(40)
    end

    trait :name_41 do
      name Faker::Lorem.characters(41)
    end
  end
end
