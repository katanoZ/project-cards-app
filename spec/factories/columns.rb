FactoryBot.define do
  factory :column do
    sequence(:name) { |n| "カラム#{n}" }
    association :project

    after(:build) { |column| column.operator = FactoryBot.create(:user) }

    trait :name_40 do
      name '1234567890123456789012345678901234567890'
    end

    trait :name_41 do
      name '12345678901234567890123456789012345678901'
    end
  end
end
