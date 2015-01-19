# This is a user factory, to simulate a user object
FactoryGirl.define do
  	factory :user, class: User do
    	first_name "John"
    	last_name  "Doe"
    	email "nico_dubus@hotmail.com"
    	encrypted_password "password"
	end
end