# coding: utf-8

User.create!(name: "管理者",
    email: "admin@email.com",
    department: "システム部",   
    password: "password",
    password_confirmation: "password",
    admin: true,
    superior: false)
User.create!(name: "上長A",
    email: "superior-a@email.com",
    department: "統括部",    
    password: "password",
    password_confirmation: "password",
    admin: false,
    superior: true)
User.create!(name: "上長B",
    email: "superior-b@email.com",
    password: "password",
    department: "フリーランス部",    
    password_confirmation: "password",
    admin: false,
    superior: true)