require 'spec_helper'
require 'rails_helper'
require 'capybara/rspec'

feature "user logs into site" do 

	scenario "User arrives at site and logs in" do
		visit "purchase_orders#index"
		fill_in('Email', :with => 'nico.dubus17@gmail.com')
		fill_in('Password', :with => 'password')
		click_button('Log in')
		#page.should have_content("All")
	end

	user = User.create(:first_name => "Nicolas", :last_name => "Dubus", :email => "nico_dubus@hotmail.com", :encrypted_password => "password")
	login(:user)

	scenario "User arrives at main page" do 
		#visit "purchase_orders#index"
		#page.should have_content("All")
		#page.should have_content("Open")
		#page.should have_content("Archived")
		#page.should have_content("NUMBER")
		#page.should have_content("DATE SENT")
		#page.should have_content("VENDOR")
		#page.should have_content("LABEL")
		#page.should have_content("STATUS")
		#page.should have_link("Purchase Orders", :href=>"purchase_orders#index")
		#page.should have_link("vendors", :href=>"vendors#index")
		#page.should have_link("settings", :href=>"settings#index")
		#page.should have_link("account", :href=>"account#index")
	end
end
