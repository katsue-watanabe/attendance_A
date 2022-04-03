# coding: utf-8

User.create!(name: "管理者",
    email: "admin@email.com",
    password: "password",
    password_confirmation: "password",
    admin: true,
    superior: true)