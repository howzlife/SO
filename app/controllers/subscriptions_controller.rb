class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @subscriptions = Subscription.all
    respond_with(@subscriptions)
  end

  def show
    respond_with(@subscription)
  end

  def new
    @subscription = Subscription.new
    respond_with(@subscription)
  end

  def edit
  end

  def create
    @subscription = Subscription.new(subscription_params)
    current_user.subscription = @subscription
    plan = params[:plan]
    name = current_user.first_name + " " + current_user.last_name
    if @subscription.save_with_payment(plan[0], current_user.email, name)
      redirect_to @subscription, :notice => "Thank you for subscribing!"
    else
      render :new
    end
  end

  def update
    @subscription.update(subscription_params)
    respond_with(@subscription)
  end

  def destroy
    @subscription.destroy
    respond_with(@subscription)
  end

  private
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def subscription_params
      # add all the fields you want to allow to be updated via your form... 
      # example below is just :name, :email but you get the idea.
      params.require(:subscription).permit(:plan, :id) 
    end
end
