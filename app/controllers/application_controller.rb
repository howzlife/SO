class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_var


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
