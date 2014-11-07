class SettingsController < ApplicationController
  before_action :set_settings, only: [:show, :edit, :update, :destroy]

  def index
    @addresses = Address.all
	end
end
