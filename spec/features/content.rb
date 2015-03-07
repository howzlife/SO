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
		@user = FactoryGirl.create(:user)
		@user.write_attribute(:company, FactoryGirl.create(:company))

		@company = @user.read_attribute(:company)  #FactoryGirl.create(:company)
		#@user_attributes = FactoryGirl.attributes_for(:user)
		# @company.write_attribute(:user, @user)
		@company.write_attribute(:users, [@user]) 		

		login_as(@company.read_attribute(:user))
		#login_as(@company.read_attribute(:user))
	end

	# before(:each) do
	# 	DatabaseCleaner.start
	# 	@company = FactoryGirl.create(:company)
		
	# 	@user = FactoryGirl.create(:user)
	# 	@company.write_attribute(:user, @user)
	# 	login_as(@company.read_attribute(:user))
	# end	

	after(:each) do 
		DatabaseCleaner.clean
	end

	# it "PO Index page should have correct content" do
	# 	visit purchase_orders_path
	# 	expect(page).to have_content("Working POs")
	# 	expect(page).to have_content("Open")
	# 	expect(page).to have_content("Closed")
	# 	expect(page).to have_content("Archived")
	# 	expect(page).to have_content("Deleted")
	# 	expect(page).to have_css("i.fa.fa-search.fa-fw")
	# 	expect(page).to have_content("No purchase orders found. Click the button above to create a new one.")
	# end

	# describe "New PO functionality" do

	# 	it "Attempting to create a new PO without setting an address should redirect to address path" do
	# 		visit purchase_orders_path
	# 		within (".button") do
	# 			click_button("Create New PO")
	# 		end
	# 		 visit new_purchase_order_path
	# 		 expect(current_path).to eq new_address_path
	# 		 message = find "p.notice"
	# 		 expect(message).to be
	# 		 expect(message.text).to include("address")
	# 	end

	# 	it "Attempting to create a new PO without setting a vendor should redirect to vendors page" do
	# 		visit purchase_orders_path
	# 		within (".button") do
	# 			click_button("Create New PO")
	# 		end
	# 		 @user.company.write_attribute(:addresses, [FactoryGirl.build(:address)])
	# 		 visit new_purchase_order_path
	# 		 expect(current_path).to eq new_vendor_path
	# 		 message = find "p.notice"
	# 		 expect(message.text).to include("Vendor")
	# 		 expect(page).to have_content("Add a Vendor")
	# 	end

	# 	it "Attempting to create a new PO with no prefix should redirect to Prefix page" do
	# 		visit purchase_orders_path
	# 		within (".button") do
	# 			click_button("Create New PO")
	# 		end
	# 		 @user.company.write_attribute(:addresses, [FactoryGirl.build(:address)])
	# 		 @user.company.write_attribute(:vendors, [FactoryGirl.build(:vendor)])
	# 		 visit new_purchase_order_path
	# 		 expect(current_path).to eq settings_path
	# 		 message = find "p.notice"
	# 		 expect(message.text).to include("prefix")
	# 	end
	# end

	# describe "Sending a new PO" do
	# 	it "Should not create a new PO if fields are left blank" do
	# 		visit purchase_orders_path
	# 		@user.company.write_attribute(:addresses, [FactoryGirl.build(:address)])
	# 		@user.company.write_attribute(:vendors, [FactoryGirl.build(:vendor)])
	# 		@user.company.write_attribute(:prefix, "WDB")
	# 		visit new_purchase_order_path
	# 		expect(current_path).to eq new_purchase_order_path
	# 		button = find("#btn-send-email")
	# 		expect{(button).click}.to change{PurchaseOrder.count}.by(0)
	# 	end	

	# 	it "Should create a new Purchase Order with correct attributes" do
	# 		visit purchase_orders_path
	# 		@user.company.write_attribute(:addresses, [FactoryGirl.build(:address)])
	# 		@user.company.write_attribute(:vendors, [FactoryGirl.build(:vendor)])
	# 		@user.company.write_attribute(:prefix, "WDB")
	# 		visit new_purchase_order_path
	# 		expect(current_path).to eq new_purchase_order_path
	# 		print page.html
	# 		page.select('Test Vendor', from: "purchase_order[vendor]")
	# 		fill_in("purchase_order[description]", with: "test PO 123")
	# 		button = find("#btn-send-email")

	# 		page.select("Home Base", from: "purchase_order[address]")
	# 		clickBlock = click_button("btn-send-fax")
	# 		expect do 
	# 			(button).click
	# 			byebug
	# 			message = find("p.notice")
	# 			expect(message.text).to include("Success")
	# 		end.to change{PurchaseOrder.count}.by(1)
	# 	end
	# end

	describe "Closed PO functionality" do 
		it "Closed Purchase Order should duplicate as new" do 
			visit purchase_orders_path
			purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
			@company.write_attribute(:purchase_order, purchase_order)
			purchase_order.write_attribute(:company, @company)
			visit purchase_order_path(purchase_order.read_attribute(:id))
			expect(current_path).to eq purchase_order_path(purchase_order.read_attribute(:id))
			puts @company.inspect
			puts page.html
			
			expect{find("#duplicate-as-new-btn").click}.to change{PurchaseOrder.count}.by(1)
			new_purchase_order = PurchaseOrder.last
			expect(new_purchase_order.read_attribute(:date_required)).to equal(purchase_order.read_attribute(:date_required))
		end
	end

end
