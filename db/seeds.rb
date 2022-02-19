# coding: utf-8

User.create!(name: "渡辺克江",
    email: "sample@email.com",
    password: "password",
    password_confirmation: "password",
    admin: true)

20.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
        email: email,
        password: password,
        password_confirmation: password)
end