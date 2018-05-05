#users
10.times do |n|
  facebook_hash = Faker::Omniauth.facebook
  name = facebook_hash[:info][:name]
  provider = facebook_hash[:provider]
  uid = facebook_hash[:uid]
  image_url = facebook_hash[:info][:image]

  User.create!(
  name: name,
  provider: provider,
  uid: uid,
  remote_image_url: image_url,
  )
end

#projects
100.times do |n|
  Project.create!(
    name: "プロジェクト#{n + 1}",
    summary: Faker::Hacker.say_something_smart,
    user_id: User.ids.sample,
  )
end

#my_projects（最初にアプリでユーザ登録してから、次にseedデータを作成する）
my_user = User.first
100.times do |n|
  Project.create!(
    name: "プロジェクト#{n + 1001}",
    summary: Faker::Hacker.say_something_smart,
    user: my_user,
  )
end
