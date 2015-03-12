require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_var
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index
    if params[:resend_instructions]
      current_user.resend_confirmation_instructions
      flash[:notice] = "Confirmation instructions were re-sent"
    end
  end

  protected
    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :is_female, :date_of_birth) }
    end

  private
  def set_var
  	if user_signed_in?
      #if current user has a company, use it, if not, create it.
      if current_user.company.present?
        @company = current_user.company 
      else 
        current_user.company = Company.new
        current_user.company.save
      end
      return current_user.company
    end
  end
end
