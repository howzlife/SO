

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
  end

  factory :company, class: Company do
    name "Vandelay"
    sendfromname "David"
    email "babycakes@email.com"
    fax "613-725-7397"
    telephone "613-725-7397"
    prefix "VDL"

    trait :has_address do
      addresses{[FactoryGirl.build(:address)]}
    end

    trait :has_vendor do
      vendors{[FactoryGirl.build(:vendor)]}
    end
  end

  factory :fax do
    recipient_name "MyString"
    company_name "MyString"
    fax_number "MyString"
    subject "MyString"
    content "MyText"
  end

  # FFaker
  factory :purchase_order do
    number { "WDC-021-#{rand(100..999)}" }
    date DateTime.current
    status "draft"
    description "test description"
    # description { FFaker::Lorem.sentence }
    date_required { Time.zone.today + rand(1..900).days }
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

    trait :as_cancelled do
      status "cancelled"
    end

   trait :as_archived do
      was_archived true
   end

   trait :unarchive do
      was_archived false
   end

   trait :was_deleted do
      was_deleted true
   end

   trait :undelete do
     was_deleted false
   end
  end

	factory :confirmed_user, class: User do
  	first_name "John"
  	last_name  "Doe"
  	email { "user-#{rand(10_000)}@example.com" }
  	password "TEST123TEST"
    confirmed_at Time.zone.now - 1.minute
  end

  factory :unconfirmed_user, class: User do
    first_name "John"
    last_name  "Doe"
    email { "user-#{rand(10_000)}@example.com" }
    password "TEST123TEST"
  end

  factory :vendor, class: Vendor do
  name "Test Vendor"
  email "Nick@nick.com"
  contact "Nick"
  telephone "613-725-7397"
  fax "613-725-7397"
  end

  factory :subscription, class: Subscription do
    stripe_customer_token "not_really_a_token"
  end

  factory :plan, class: Plan do
    name "trial"
    max_monthly_po_count 2
    max_email_po 2
    max_fax_po 2
    max_vendor_count 2
    can_duplicate true
      trait :basic do
        name "Basic Plan"
        max_monthly_po_count 10
        max_vendor_count 5
      end

      trait :better do
        name "Better Plan"
        max_monthly_po_count 20
        max_vendor_count 10
      end
    end
end