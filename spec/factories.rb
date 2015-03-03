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

  factory :company, class: Company do
    name "Vandelay"
    sendfromname "David"
    email "babycakes@email.com"
    fax "613-725-7397"
    telephone "613-725-7397"
    prefix "VDL"
    # association :address, strategy: :build
    # association :vendor, strategy: :build
    after(:create) do |c|
    #   # byebug
    c.vendors.build(FactoryGirl.attributes_for(:vendor)).save
    c.addresses.build(FactoryGirl.attributes_for(:address)).save
    end
  end 

  factory :fax do
    recipient_name "MyString"
    company_name "MyString"
    fax_number "MyString"
    subject "MyString"
    content "MyText"
  end

  factory :purchase_order do
    number { "WDC-021-#{rand(100..999)}" }
    date DateTime.current
    status "draft"
    description "test description"
    date_required "May 5th 2015"
    archived false
    was_deleted false
    after (:build) do |po|
      po.write_attribute(:vendor, (FactoryGirl.attributes_for(:vendor)))
    end
    trait :as_draft do
      status "draft"
    end
   trait :as_open do
      status "open"
    end
   trait :as_closed do
      status "closed"
    end
  end

	factory :user, class: User do
  	first_name "John"
  	last_name  "Doe"
  	email { "user-#{rand(10_000)}@example.com" }
  	password "TEST123TEST"
    confirmed_at Time.zone.now - 1.minute
  end

  factory :vendor, class: Vendor do
  name "Test Vendor"
  email "Nick@nick.com"
  contact "Nick"
  telephone "613-725-7397"
  fax "613-725-7397"
  end
end