require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
require 'database_cleaner'
require 'vcr'
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

	 # describe "Pre-PO Creation logic" do
	 # 	it "Attempting to create a new PO without setting an address should redirect to address path" do
	 # 		visit purchase_orders_path
	 # 		within (".button") do
	 # 			click_button("Create New PO")
	 # 		end
	 # 		 visit new_purchase_order_path
	 # 		 expect(current_path).to eq edit_company_path(@company)
	 # 		 message = find "p.notice"
	 # 		 expect(message).to be
	 # 		 expect(message.text).to include("address")
	 # 	end

	 # 	it "Attempting to create a new PO without setting a vendor should redirect to vendors page" do
	 # 		visit purchase_orders_path
	 # 		within (".button") do
	 # 			click_button("Create New PO")
	 # 		end
	 # 		 @user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
	 # 		 visit new_purchase_order_path
	 # 		 expect(current_path).to eq new_vendor_path
	 # 		 message = find "p.notice"
	 # 		 expect(message.text).to include("Vendor")
	 # 		 expect(page).to have_content("New Vendor")
	 # 	end

	 # 	it "Adding the first address should set it as billing and shipping address" do 
	 # 		visit new_address_path
	 # 		fill_in("Name", with: "test")
	 # 		fill_in("address_line_1", with: "address one")
	 # 		fill_in("city", with: "Ottawa")
	 # 		fill_in("state", with: "Ontario")
	 # 		fill_in("country", with: "Canada")
	 # 		fill_in("zip", with: "K1S 5P3")
	 # 		fill_in("agent", with: "Nick")
	 # 		find(".btn-save-address").click
	 # 		@company.reload
	 # 		expect(@company.shipaddress).not_to eq nil
	 # 		expect(@company.billaddress).not_to eq nil
	 # 		expect(@company.shipaddress).to eq @company.addresses.last.id
	 # 		expect(@company.billaddress).to eq @company.addresses.last.id
	 # 	end
	 # end

	 before(:each) do
		@address = FactoryGirl.build(:address)
 		@user.company.update_attribute(:addresses, [@address])
 		@user.company.update_attribute(:shipaddress, @address.id)
 		@user.company.update_attribute(:billaddress, @address.id)
 		@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
 		visit new_purchase_order_path
		page.select('Test Vendor', from: "purchase_order[vendor]")
		page.select("Home Base", from: "purchase_order[address]")
	end

	 describe "Sending a new PO" do
	 	it "Should not create a new PO if fields are left blank" do
	 		expect(current_path).to eq new_purchase_order_path
	 		page.select("Home Base", from: "purchase_order[address]")
	 		button = find(".btn-email")
	 		expect{(button).click}.to change{PurchaseOrder.count}.by(0)
	 		expect(page).to have_content("Description can't be blank")
	 	end	

	 	it "Should not create a new PO when discarded" do
			# page.select('Test Vendor', from: "purchase_order[vendor]")
			# fill_in("purchase_order[description]", with: "test PO 123")
			# page.select("Home Base", from: "purchase_order[address]")
			fill_in("purchase_order[description]", with: "test PO 123")
			button = find(".btn-discard")
			expect{button.click}.to change{PurchaseOrder.count}.by(0)
			expect(current_path).to eq purchase_orders_path
		end

		it "Should create a draft PO with correct attributes when saved as draft" do
			fill_in("purchase_order[description]", with: "test PO 123")
			expect{find(".btn-save").click}.to change{PurchaseOrder.count}.by 1
			expect(current_path).to eq purchase_order_path(PurchaseOrder.last)
			expect(page).not_to have_content("History")
		end

		it "Should create a new Purchase Order with correct attributes, and should send by email correctly" do
			# page.select('Test Vendor', from: "purchase_order[vendor]")
			# fill_in("purchase_order[description]", with: "test PO 123")
			# page.select("Home Base", from: "purchase_order[address]")
			fill_in("purchase_order[description]", with: "test PO 123")
			button = find(".btn-email")
			expect{button.click}.to change{ActionMailer::Base.deliveries.count}.by(1)
			expect(current_path).to eq purchase_order_path(PurchaseOrder.last)
			expect(page).to have_content "History"
		end

		it "Should create a new Purchase Order with correct attributes, and should send by fax correctly" do
			# page.select('Test Vendor', from: "purchase_order[vendor]")
			# fill_in("purchase_order[description]", with: "test PO 123")
			# page.select("Home Base", from: "purchase_order[address]")
			fill_in("purchase_order[description]", with: "test PO 123")
			expect{find(".btn-fax").click}.to change{PurchaseOrder.count}.by(1)
			expect(current_path).to eq purchase_order_path(PurchaseOrder.last)
			expect(page).to have_content "History"
		end

		it "Should create a new Purchase Order with correct attributes when marked as Open" do
			# page.select('Test Vendor', from: "purchase_order[vendor]")
			# fill_in("purchase_order[description]", with: "test PO 123")
			# page.select("Home Base", from: "purchase_order[address]")
			fill_in("purchase_order[description]", with: "test PO 123")
			expect{find(".btn-open").click}.to change{PurchaseOrder.count}.by(1)
			expect(current_path).to eq purchase_order_path(PurchaseOrder.last)
			expect(page).to have_content "History"
		end
	end

	# describe "Draft PO Functionality" do 
	# 	it "A draft PO should send the correct params hash with no editing required" do 
	# 		visit purchase_orders_path
	# 		expect(current_path).to eq purchase_orders_path
	# 		purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
	# 		@company.update_attribute(:purchase_orders, [purchase_order])
	# 		purchase_order.update_attribute(:company, @company)
	# 		visit purchase_order_path(purchase_order.read_attribute(:id))
	# 		expect(current_path).to eq purchase_order_path(purchase_order.read_attribute(:id))
	# 		puts @company.inspect
	# 		within (".elipsis.btn") do
	# 			expect{find(".link-duplicate").click}.to change{PurchaseOrder.count}.by(1)
	# 		end
	# 		new_purchase_order = PurchaseOrder.last
	# 		expect(new_purchase_order.read_attribute(:description)).to eq(purchase_order.read_attribute(:description))
	# 		# expect(new_purchase_order.read_attribute(:vendor)).to eq (purchase_order.read_attribute(:vendor))
	# 		# expect(new_purchase_order.read_attribute(:address)).to eq (purchase_order.read_attribute(:address))
	# 		expect(new_purchase_order.read_attribute(:label)).to eq (purchase_order.read_attribute(:label))
	# 		expect(new_purchase_order.read_attribute(:number)).not_to eq(purchase_order.read_attribute(:number))
	# 		expect(current_path).to eq purchase_order_path(new_purchase_order)
	# 		fill_in("purchase_order[description]", with: "new PO Description")
	# 		find(".btn-email").click
	# 		# expect(params[:vendor]).not_to eq nil 
	# 	end

		# it "clicking the bcc box should send the user a copy via email, when he is emailing" do
		# 	visit purchase_orders_path
		# 	@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
		# 	@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
		# 	visit new_purchase_order_path
		# 	expect(current_path).to eq new_purchase_order_path
		# 	page.select('Test Vendor', from: "purchase_order[vendor]")
		# 	fill_in("purchase_order[description]", with: "test PO 123")
		# 	button = find(".btn-email")

		# 	page.select("Home Base", from: "purchase_order[address]")
			
		# 	find(".btn-bcc").click
		# 	expect{find(".btn-email").click}.to change{ActionMailer::Base.deliveries.count}.by(2)
		# end

		# it "clicking the bcc box should send the user a copy via email, when he is faxing" do
		# 	visit purchase_orders_path
		# 	@user.company.update_attribute(:addresses, [FactoryGirl.build(:address)])
		# 	@user.company.update_attribute(:vendors, [FactoryGirl.build(:vendor)])
		# 	visit new_purchase_order_path
		# 	expect(current_path).to eq new_purchase_order_path
		# 	page.select('Test Vendor', from: "purchase_order[vendor]")
		# 	fill_in("purchase_order[description]", with: "test PO 123")
		# 	button = find(".btn-email")

		# 	page.select("Home Base", from: "purchase_order[address]")
		# 	find(".btn-bcc").click
		# 	expect{find(".btn-fax").click}.to change{ActionMailer::Base.deliveries.count}.by(1)
		# end
	# end

	# describe "Duplicate as new functionality" do 
	# 	# it "Duplicate as new should function as expected" do 
	# 	# 	visit purchase_orders_path
	# 	# 	expect(current_path).to eq purchase_orders_path
	# 	# 	purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
	# 	# 	@company.update_attribute(:purchase_orders, [purchase_order])
	# 	# 	purchase_order.update_attribute(:company, @company)
	# 	# 	visit purchase_order_path(purchase_order.read_attribute(:id))
	# 	# 	expect(current_path).to eq purchase_order_path(purchase_order.read_attribute(:id))
	# 	# 	puts @company.inspect
	# 	# 	within (".elipsis.btn") do
	# 	# 		expect{find(".link-duplicate").click}.to change{PurchaseOrder.count}.by(1)
	# 	# 	end
	# 	# 	new_purchase_order = PurchaseOrder.last
	# 	# 	expect(new_purchase_order.read_attribute(:description)).to eq(purchase_order.read_attribute(:description))
	# 	# 	# expect(new_purchase_order.read_attribute(:vendor)).to eq (purchase_order.read_attribute(:vendor))
	# 	# 	# expect(new_purchase_order.read_attribute(:address)).to eq (purchase_order.read_attribute(:address))
	# 	# 	expect(new_purchase_order.read_attribute(:label)).to eq (purchase_order.read_attribute(:label))
	# 	# 	expect(new_purchase_order.read_attribute(:number)).not_to eq(purchase_order.read_attribute(:number))
	# 	# 	expect(current_path).to eq purchase_order_path(new_purchase_order)
	# 	# 	fill_in("purchase_order[description]", with: "new PO Description")
	# 	# 	find(".btn-email").click
	# 	# 	# expect(page).to have_content("new PO Description")
	# 	# end
	# end

	describe "Archived PO's" do

		it "an Archived PO should keep track of when it was last archived" do
			purchase_order = FactoryGirl.create(:purchase_order, :as_closed)
			visit purchase_order_path(purchase_order)
			find(".btn-archive").click
			purchase_order.reload
			expect(purchase_order.last_archived_on).not_to eq nil
		end

		it "a Deleted PO should keep track of when it was last deleted" do
			purchase_order = FactoryGirl.create(:purchase_order, :as_cancelled)
			visit purchase_order_path(purchase_order)
			find(".btn-delete").click
			purchase_order.reload
			expect(purchase_order.last_deleted_on).not_to eq nil
		end

	end
end
