require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner[:mongoid, {:connection => :myorderboard_test}]
include Warden::Test::Helpers
Warden.test_mode!

describe "The Purchase Order Process" do 

	before(:each) do
		DatabaseCleaner.start
		FactoryGirl.create(:plan)	
		@user = FactoryGirl.create(:confirmed_user)
		@company = FactoryGirl.create(:company)
		@company.update_attribute(:users, [@user]) 		
		login_as(@user)
	end

	after(:each) do 
		DatabaseCleaner.clean
	end

	 it "PO Index page should have correct content" do
	 	visit purchase_orders_path
	 	expect(page).to have_content("All POs")
	 	expect(page).to have_content("Open")
	 	expect(page).to have_content("Closed")
	 	expect(page).to have_content("Archived")
	 	expect(page).to have_content("Deleted")
	 	expect(page).to have_css("i.fa.fa-search.fa-fw")
	 	expect(page).to have_content("No purchase orders found. Click the button above to create a new one.")
	 end

	 describe "New PO functionality" do
	 	it "Attempting to create a new PO without setting an address should redirect to address path" do
	 		visit purchase_orders_path
	 		within (".button") do
	 			click_button("Create New PO")
	 		end
	 		 visit new_purchase_order_path
	 		 expect(current_path).to eq edit_company_path(@company)
	 		 message = find "p.notice"
	 		 expect(message).to be
	 		 expect(message.text).to include("address")
	 	end

	 	it "Attempting to create a new PO without setting a vendor should redirect to vendors page" do
	 		visit purchase_orders_path
	 		within (".button") do
	 			click_button("Create New PO")
	 		end
	 		 @user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	 		 visit new_purchase_order_path
	 		 expect(current_path).to eq new_vendor_path
	 		 message = find "p.notice"
	 		 expect(message.text).to include("Vendor")
	 		 expect(page).to have_content("New Vendor")
	 	end
	 end

	 describe "Sending a new PO" do
	 	it "Should not create a new PO if fields are left blank" do
	 		visit purchase_orders_path
	 		@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	 		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
	 		visit new_purchase_order_path
	 		expect(current_path).to eq new_purchase_order_path
	 		button = find(".btn-email")
	 		expect{(button).click}.to change{PurchaseOrder.count}.by(0)
	 		expect(page).to have_content("Description can't be blank")
	 	end	

		it "Should create a new Purchase Order with correct attributes" do
			visit purchase_orders_path
			@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
			@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
			visit new_purchase_order_path
			expect(current_path).to eq new_purchase_order_path
			page.select('Test Vendor', from: "purchase_order[vendor]")
			fill_in("purchase_order[description]", with: "test PO 123")
			button = find(".btn-email")

			page.select("Home Base", from: "purchase_order[address]")
			expect{find(".btn-fax").click}.to change{PurchaseOrder.count}.by(1)
		end
	end

	describe "Closed PO functionality" do 
		it "Closed Purchase Order should duplicate as new" do 
			visit purchase_orders_path
			expect(current_path).to eq purchase_orders_path
			purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
			@company.update_attribute(:purchase_orders, [purchase_order])
			purchase_order.update_attribute(:company, @company)
			visit purchase_order_path(purchase_order.read_attribute(:id))
			expect(current_path).to eq purchase_order_path(purchase_order.read_attribute(:id))
			puts @company.inspect
			within (".elipsis.btn") do
				puts page.html
				expect{find(".link-duplicate").click}.to change{PurchaseOrder.count}.by(1)
			end
			new_purchase_order = PurchaseOrder.last
			expect(new_purchase_order.read_attribute(:description)).to eq(purchase_order.read_attribute(:description))
			expect(new_purchase_order.read_attribute(:number)).not_to eq(purchase_order.read_attribute(:number))
		end
	end
end

describe "The unconfirmed user process" do 

	before(:each) do
		DatabaseCleaner.start
		FactoryGirl.create(:plan)	
		@user = FactoryGirl.create(:unconfirmed_user)
		@company = FactoryGirl.create(:company)
		@company.update_attribute(:users, [@user]) 		
		login_as(@user)
	end

	after(:each) do 
		DatabaseCleaner.clean
	end

	describe "Resend confirmation email" do
		it "Re-sends confirmation email for unconfirmed user when link is clicked" do
			visit purchase_orders_path
			expect(page).to have_content('Resend Confirmation Email')
			ActionMailer::Base.deliveries.clear
			click_link('Resend Confirmation Email')
			expect(ActionMailer::Base.deliveries.count).to eq (1)
		end
	end
end

describe "The subscription and plan logic" do 

	before(:each) do
		DatabaseCleaner.start
		FactoryGirl.create(:plan)
		@user = FactoryGirl.create(:confirmed_user)
		@company = FactoryGirl.create(:company)
		@company.update_attribute(:users, [@user]) 		
		# @subscription = FactoryGirl.create(:subscription)
		# @plan = FactoryGirl.create(:plan)
		# @user.update_attribute(:subscription, @subscription)
		# @user.subscription.update_attribute(:plan, @plan)
		login_as(@user)
	end

	after(:each) do 
		DatabaseCleaner.clean
	end

	it "A new user should automatically get a subscription, and that subscription should get a plan" do
		expect(@user.subscription).to_not eq nil
		expect(@user.subscription.plan).to_not eq nil
	end
	
	it "A trial plan should have an expiry date" do
		expect(@user.subscription.expires_at).to eq(Date.today + 18)
	end

	it "A subscription should have a maximum number of POs it can send" do
		expect(@user.subscription.monthly_po_count).to eq 0
	end

	it "A plan should have a max PO count" do
		expect(@user.subscription.plan.max_monthly_po_count).to eq 2
	end

	it "when a User sends a PO, the monthly po count should increase" do
		visit purchase_orders_path
		@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
		visit new_purchase_order_path
		expect(current_path).to eq new_purchase_order_path
		page.select('Test Vendor', from: "purchase_order[vendor]")
		fill_in("purchase_order[description]", with: "test PO 123")
		button = find(".btn-email")

		page.select("Home Base", from: "purchase_order[address]")
		old_count = @user.subscription.monthly_po_count
		find(".btn-fax").click
		@user.subscription.reload
		expect(@user.subscription.monthly_po_count).to eq 1
	end

	it "After sending the maximum amount of PO's for the month, a user should not be able to send any more PO's" do
		visit purchase_orders_path
		@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
		visit new_purchase_order_path
		expect(current_path).to eq new_purchase_order_path
		page.select('Test Vendor', from: "purchase_order[vendor]")
		fill_in("purchase_order[description]", with: "test PO 123")
		page.select("Home Base", from: "purchase_order[address]")
		find(".btn-fax").click
		@user.subscription.reload
		expect(@user.subscription.monthly_po_count).to eq 1
		expect(current_path).to eq purchase_order_path(PurchaseOrder.last)
		find(".btn-fax").click
		@user.subscription.reload
		expect(@user.subscription.monthly_po_count).to eq 2
		expect{find(".btn-fax").click}.to change{ActionMailer::Base.deliveries.count}.by 0
		@user.subscription.reload
		expect(@user.subscription.monthly_po_count).to eq 2

	end

end
