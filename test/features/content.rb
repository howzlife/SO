require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature "user logs into site" do 
	user = FactoryGirl.build(:user)

	scenario "User arrives at site and logs in" do
		visit "purchase_orders#index"
		fill_in('Email', :with => 'nico.dubus17@gmail.com')
		fill_in('Password', :with => 'password')
		click_button('Log in')
	end

	scenario "User arrives at main page" do 
		login_as(user, :scope => :user)
		visit "purchase_orders#index"
		page.should have_content("All")
		page.should have_content("Open")
		page.should have_content("Archived")
		logout(:user)
	end

	scenario "Should load purchase orders menu" do 
		login_as(user, :scope => :user)
		visit "purchase_orders#index"
		page.should have_content("NUMBER")
		page.should have_content("DATE SENT")
		page.should have_content("VENDOR")
		page.should have_content("LABEL")
		page.should have_content("STATUS")
		logout(:user)
	end

	scenario "Sidebar should load with links" do
		login_as(user, :scope => :user)
		visit "purchase_orders@index"
		page.should have_content("New Purchase Order")
		page.should have_content("Purchase Orders")
		page.should have_content("Vendors")
		page.should have_content("Settings")
		page.should have_content("Account")
	end


end
