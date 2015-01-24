class Subscription
  include Mongoid::Document
  belongs_to :user

  attr_accessor :stripe_card_token

  def save_with_payment(plan, email, name)
  	if valid?
  		customer = Stripe::Customer.create(description: name, email: email, plan: plan, card: stripe_card_token)
  		stripe_customer_token = customer.id 
  		save!
  	end
  rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while creating customer: #{e.message}"
  	errors.add :base, "There was a problem with your credit card."
  	false
  end
end
