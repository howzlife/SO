require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner[:mongoid, {:connection => :myorderboard_test}]
include Warden::Test::Helpers
Warden.test_mode!

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
		expect(@user.subscription.plan_type).to eq "trial"
	end
	
	it "A trial plan should have an expiry date" do
		expect(@user.subscription.expires_at).to eq(Date.today + 18)
	end

	it "A subscription should have a maximum number of POs it can send" do
		expect(@user.subscription.monthly_po_count).to eq 0
	end

	it "A plan should have a max PO count" do
		 expect(Plan.find_by(name: "trial").max_monthly_po_count).to eq 2
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
		expect(page).to have_content('monthly PO limit')
	end

end
