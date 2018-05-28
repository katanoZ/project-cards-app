FactoryBot.define do
  factory :user, aliases: [:assignee] do
    name '山田太郎'
    provider { Faker::Omniauth.facebook[:provider] }
    uid { Faker::Omniauth.facebook[:uid] }
  end
end
