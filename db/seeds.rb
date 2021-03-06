# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Create a main sample user
User.create!(name: "Stas", email: "stas@stas.com",
             password:     "qwerty", password_confirmation: "qwerty", 
             admin:        true, 
             activated:    true, 
             activated_at: Time.zone.now)

#Generate a bunch of additional users
99.times do |n|
  name = Faker::Name.name
  email = "user_#{n + 1}@example.com"
  password = "qwerty"
  User.create(name: name, email: email, password: password, password_confirmation: password, 
              activated:    true, 
              activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6) # or     .limit(6)
50.times do 
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |u| u.microposts.create!(content: content) }
end

