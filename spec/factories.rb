# This is a user factory, to simulate a user object
FactoryGirl.define do  

  factory :fax do
    recipient_name "MyString"
    company_name "MyString"
    fax_number "MyString"
    subject "MyString"
    content "MyText"
  end

  factory :purchase_order do
    number "WDC-021-021"
    date DateTime.current
    status "draft"
    description "test description"
    date_required "May 5th 2015"
    archived false
    was_deleted false
  end

	factory :user, class: User do
  	first_name "John"
  	last_name  "Doe"
  	email { "user-#{rand(10_000)}@example.com" }
  	password "TEST123TEST"
 end
end