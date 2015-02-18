class Subscription
  include Mongoid::Document
  belongs_to :user
  field :plan, type: String
  field :stripe_customer_token, type: String

  attr_accessor :stripe_card_token

  def save_with_payment(plan, email, name)
  	if valid?
  		customer = Stripe::Customer.create(description: name, email: email, plan: plan, card: stripe_card_token)
  		write_attribute(:stripe_customer_token, customer.id)
  		save!
    end
    rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while creating customer: #{e.message}"
  	errors.add :base, "There was a problem with your credit card."
  	false
  end

  def update_plan(updated_plan)
    customer = Stripe::Customer::retrieve(read_attribute(:stripe_customer_token))
    sub = customer.subscriptions.retrieve(customer.subscriptions.data[0].id)
    sub.plan = updated_plan[0]
    sub.save
    customer.save
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while updating customer: #{e.message}"
      false
  end

  def cancel_plan
    customer = Stripe::Customer::retrieve(read_attribute(:stripe_customer_token))
    customer.delete
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while deleting customer: #{e.message}"
      false
  end

  def update_card(attributes)
    customer = Stripe::Customer::retrieve(read_attribute(:stripe_customer_token))
    customer.card = attributes[:stripe_card_token]
    customer.save
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while updating card: #{e.message}"
      false
  end
end
