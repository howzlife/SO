require 'test_helper'
require 'database_cleaner'
require 'purchase_orders_controller'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner[:mongoid, {:connection => :myorderboard_test}]
include Warden::Test::Helpers
Warden.test_mode!

class POControllerTest < ActiveSupport::TestCase

	def setup
		DatabaseCleaner.start
	end

	user = FactoryGirl.build(:user)
	login_as(user, :scope => :user)

	test "the truth" do 
		assert_equal(user.email, user.email, "Hi, my name is!")
	end

	def teardown
		DatabaseCleaner.clean
	end

end