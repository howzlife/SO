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

	#  it "PO Index page should have correct content" do
	#  	visit purchase_orders_path
	#  	expect(page).to have_content("All POs")
	#  	expect(page).to have_content("Open")
	#  	expect(page).to have_content("Closed")
	#  	expect(page).to have_content("Archived")
	#  	expect(page).to have_content("Deleted")
	#  	expect(page).to have_css("i.fa.fa-search.fa-fw")
	#  	expect(page).to have_content("No purchase orders found. Click the button above to create a new one.")
	#  end

	#  describe "New PO functionality" do
	#  	it "Attempting to create a new PO without setting an address should redirect to address path" do
	#  		visit purchase_orders_path
	#  		within (".button") do
	#  			click_button("Create New PO")
	#  		end
	#  		 visit new_purchase_order_path
	#  		 expect(current_path).to eq edit_company_path(@company)
	#  		 message = find "p.notice"
	#  		 expect(message).to be
	#  		 expect(message.text).to include("address")
	#  	end

	#  	it "Attempting to create a new PO without setting a vendor should redirect to vendors page" do
	#  		visit purchase_orders_path
	#  		within (".button") do
	#  			click_button("Create New PO")
	#  		end
	#  		 @user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	#  		 visit new_purchase_order_path
	#  		 expect(current_path).to eq new_vendor_path
	#  		 message = find "p.notice"
	#  		 expect(message.text).to include("Vendor")
	#  		 expect(page).to have_content("New Vendor")
	#  	end
	#  end

	#  describe "Sending a new PO" do
	#  	it "Should not create a new PO if fields are left blank" do
	#  		visit purchase_orders_path
	#  		@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	#  		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
	#  		visit new_purchase_order_path
	#  		expect(current_path).to eq new_purchase_order_path
	#  		button = find(".btn-email")
	#  		expect{(button).click}.to change{PurchaseOrder.count}.by(0)
	#  		expect(page).to have_content("Description can't be blank")
	#  	end	

	# 	it "Should create a new Purchase Order with correct attributes" do
	# 		visit purchase_orders_path
	# 		@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	# 		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
	# 		visit new_purchase_order_path
	# 		expect(current_path).to eq new_purchase_order_path
	# 		page.select('Test Vendor', from: "purchase_order[vendor]")
	# 		fill_in("purchase_order[description]", with: "test PO 123")
	# 		button = find(".btn-email")

	# 		page.select("Home Base", from: "purchase_order[address]")
	# 		expect{find(".btn-fax").click}.to change{PurchaseOrder.count}.by(1)
	# 	end
	# end

	describe "Duplicate as new functionality" do 
		it "Duplicate as new should function as expected" do 
			visit purchase_orders_path
			expect(current_path).to eq purchase_orders_path
			purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
			@company.update_attribute(:purchase_orders, [purchase_order])
			purchase_order.update_attribute(:company, @company)
			visit purchase_order_path(purchase_order.read_attribute(:id))
			expect(current_path).to eq purchase_order_path(purchase_order.read_attribute(:id))
			puts @company.inspect
			within (".elipsis.btn") do
				expect{find(".link-duplicate").click}.to change{PurchaseOrder.count}.by(1)
			end
			new_purchase_order = PurchaseOrder.last
			expect(new_purchase_order.read_attribute(:description)).to eq(purchase_order.read_attribute(:description))
			# expect(new_purchase_order.read_attribute(:vendor)).to eq (purchase_order.read_attribute(:vendor))
			# expect(new_purchase_order.read_attribute(:address)).to eq (purchase_order.read_attribute(:address))
			expect(new_purchase_order.read_attribute(:label)).to eq (purchase_order.read_attribute(:label))
			expect(new_purchase_order.read_attribute(:number)).not_to eq(purchase_order.read_attribute(:number))
			expect(current_path).to eq purchase_order_path(new_purchase_order)
			fill_in("purchase_order[description]", with: "new PO Description")
			find(".btn-email").click
			expect(page).to have_content("new PO Description")
		end
	end
end
