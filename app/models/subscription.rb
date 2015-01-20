class Subscription
  include Mongoid::Document
  belongs_to :user

  attr_accessor :stripe_card_token
end
