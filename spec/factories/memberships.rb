FactoryBot.define do
  factory :membership do
    association :project
    association :user
  end
end
