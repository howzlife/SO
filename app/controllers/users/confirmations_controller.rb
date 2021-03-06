class Users::ConfirmationsController < Devise::ConfirmationsController
  require 'mail_chimp.rb'

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  def resend_confirmation_email
    current_user.resend_confirmation_instructions
      respond_to do |format|
        format.html {redirect_to purchase_orders_path, notice: "Confirmation Email has been re-sent"}
      end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
   def after_resending_confirmation_instructions_path_for(resource_name)
     root_path
   end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)  
    #add user to mailchimp
    if Rails.env.production?      
      mailchimp = MailChimp.new(ENV['MAILCHIMP_API_KEY'], ENV['MAILCHIMP_LIST_ID'])
      mailchimp.addmember(resource)
    end
    super(resource_name, resource)
  end
end
