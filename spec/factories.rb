# This is a user factory, to simulate a user object
FactoryGirl.define do  

  factory :address, class: Address do
    name "Home Base"
    address {
      {"address_line_1" => "742 Evergreen Terrace"}
      {"address_line_2" => "none"}
      {"city" => "Springfield"}
      {"state" => "Oregon"}
      {"country" => "USA"}
      {"zip" => "90210"}
      }
    telephone = "555-555-5555"
    fax "613-725-7397"
    agent "Dave"
    defaultflag true
  end

  factory :company do
  name "Vandelay"
  sendfromname "David"
  email "babycakes@email.com"
  fax "613-725-7397"
  telephone "613-725-7397"
  prefix "VDL"
  end

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
   # address FactoryGirl.build(:address)
 end
end