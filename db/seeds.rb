# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
# Uncomment the following to create an Admin user for Production in Jumpstart Pro
# User.create name: "name", email: "email", password: "password", password_confirmation: "password", admin: true, terms_of_service: true

["Apple", "Orange", "Eggs", "Milk"].each do |name|
  grocery = Grocery.create(name: name)
  5.times.each do
    Coupon.create(grocery_id: grocery.id, price: 20, description: "$20 off on purchase of #{grocery.name}", valid_from: DateTime.current, valid_to: 1.week.after)
  end
end
