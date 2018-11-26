User.create! name: "Example User",
  email: "admin@gmail.com",
  password: "123123",
  password_confirmation: "123123",
  admin: true

99.times do |n|
  name  = FFaker::Name.name
  email = "admin-#{n+1}@gmail.com"
  password = "password"
  User.create! name: name,
  email: email,
  password: password,
  password_confirmation: password
end

users = User.order(:created_at).take(2)
50.times do
  content = FFaker::Lorem.sentence(5)
  users.each {|user| user.microposts.create!(content: content)}
end

users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each {|followed| user.follow(followed)}
followers.each {|follower| follower.follow(user)}
