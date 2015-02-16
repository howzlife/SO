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
      redirect_to @subscription, :notice => "Subscription was successfully created!"
    else
      render :new, :notice => "Error creating subscription"
    end
  end

  def update
    @subscription = current_user.subscription
    @subscription.update(subscription_params)
    respond_to do |format|
      if params[:update_plan]
          if @subscription.update_plan(params[:plan])
            @subscription.update_attribute(:plan, params[:plan])
            format.html {redirect_to @subscription, :notice => "Congratulations! Your plan has been changed to the #{current_user.subscription.plan.to_s} " }
          else 
            format.html { render :edit, :notice => "Unable to update plan" }
          end
      elsif params[:cancel]
        if @subscription.cancel_plan 
          format.html {redirect_to new_subscription_path, :notice => "Plan successfully canceled" }
        end
      else
        if @subscription.update_card(params[:subscription])
          format.html {redirect_to @subscription, :notice => "Card was successfully updated" }
        else 
          format.html {redirect_to @subscription, :notice => "Error updating card" }
        end
      end
    end
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
      params.require(:subscription).permit(:plan, :stripe_card_token) 
    end
end
