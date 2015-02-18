require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

include Warden::Test::Helpers
Warden.test_mode!

feature "user logs into site" do 
user = FactoryGirl.build(:user)
	scenario "User arrives at site and logs in" do
		visit "purchase_orders#index"
		fill_in('Email', :with => 'nico.dubus17@gmail.com')
		fill_in('Password', :with => 'password')
		click_button('Log in')
		#page.should have_content("All")
	end


	scenario "User arrives at main page" do 
		login_as(user, :scope => :user)
		visit "purchase_orders#index"
		page.should have_content("All")
		page.should have_content("Open")
		page.should have_content("Archived")
		page.should have_content("fuck")
		#page.should have_content("DATE SENT")
		#page.should have_content("VENDOR")
		#page.should have_content("LABEL")
		#page.should have_content("STATUS")
		#page.should have_link("Purchase Orders", :href=>"purchase_orders#index")
		#page.should have_link("vendors", :href=>"vendors#index")
		#page.should have_link("settings", :href=>"settings#index")
		#page.should have_link("account", :href=>"account#index")
		logout(:user)
	end
end
