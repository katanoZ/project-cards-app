FactoryBot.define do
  factory :user, aliases: [:assignee] do
    name '山田太郎'
    provider { Faker::Omniauth.facebook[:provider] }
    uid { Faker::Omniauth.facebook[:uid] }
  end

  trait :with_5_invitations do
    after(:create) { |user| create_list(:membership, 5, user: user) }
  end

  trait :with_4_invitations_and_3_participations do
    after(:create) { |user| create_list(:membership, 4, user: user, join: false) }
    after(:create) { |user| create_list(:membership, 3, user: user, join: true) }
  end

  trait :with_6_participations do
    after(:create) { |user| create_list(:membership, 6, user: user, join: true) }
  end

  trait :with_6_host_projects do
    after(:create) { |user| create_list(:project, 6, user: user) }
  end
end
