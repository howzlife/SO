class Subscription
  include Mongoid::Document
  include Mongoid::Enum
  belongs_to :user
  field :plan_type, type: String
  field :stripe_customer_token, type: String
  field :monthly_po_count, type: Integer
  field :expires_at, type: Date

  attr_accessor :stripe_card_token


  # def initialize(attrs={})
    # @plan_id = attrs[:plan_id] 
  # end

  def save_without_payment(plan, email, name)
      customer = Stripe::Customer.create(description: name, email: email, plan: plan)
      update_attribute(:stripe_customer_token, customer.id)
      update_attribute(:monthly_po_count, 0)
      add_plan_to_subscription(plan) if save!
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
  end

  def save_with_payment(plan, email, name)
  	if valid?
  		customer = Stripe::Customer.create(description: name, email: email, plan: plan, card: stripe_card_token)
  		update_attribute(:stripe_customer_token, customer.id)
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

  def add_plan_to_subscription(current_plan)
    update_attributes!(plan_type: current_plan.to_s)
    if (current_plan == :trial)
       update_attributes!(expires_at: Date.today + 18)
    end
    save!
  end

  def can_send_po
    return monthly_po_count < Plan.find_by(name: read_attribute(:plan_type)).max_monthly_po_count
  end
end
