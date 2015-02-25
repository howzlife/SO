require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner[:mongoid, {:connection => :myorderboard_test}]
include Warden::Test::Helpers
Warden.test_mode!

describe "the sign in process" do 

	before(:each) do
		DatabaseCleaner.start
	end

	after(:each) do 
		DatabaseCleaner.clean
	end

	user = FactoryGirl.create(:user)

	it "signs me in" do
		login_as(user)
		visit "purchase_orders#index"
		#within ('all') do
		expect(page).to have_content("Active POs")
		#end

	end

	# scenario "User arrives at site and logs in" do
	# 	visit "purchase_orders#index"
	# 	expect(page).to have_content("Email")
	# 	expect(page).to have_content("Password")
	# 	expect(page).to have_content("Log in")
	# end


	# scenario "User arrives at main page" do 
	# 	login_as(user, :scope => :user)
	# 	visit "purchase_order#index"
	# 	expect(page).to have_content("Active POs")
	# 	expect(page).to have_content("Drafas")
	# 	logout(:user)
		#page.should have_content("VENDOR")
		#page.should have_content("LABEL")
		#page.should have_content("STATUS")
		#page.should have_link("Purchase Orders", :href=>"purchase_orders#index")
		#page.should have_link("vendors", :href=>"vendors#index")
		#page.should have_link("settings", :href=>"settings#index")
		#page.should have_link("account", :href=>"account#index")
	# end
end
