class SettingsController < ApplicationController
  before_action :set_settings, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @addresses = Address.all
	end
end
