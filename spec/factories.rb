# This is a user factory, to simulate a user object
FactoryGirl.define do  factory :fax do
    recipient_name "MyString"
company_name "MyString"
fax_number "MyString"
subject "MyString"
content "MyText"
  end
  factory :subscription do
    
  end

  	factory :user, class: User do
    	first_name "John"
    	last_name  "Doe"
    	email "nico_dubus@hotmail.com"
    	encrypted_password "password"
	end
end