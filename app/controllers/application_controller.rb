class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_var


  private
  def set_var
  	if user_signed_in?
    	@company = current_user.company
	end
  end
end
