class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update]
  before_action :authenticate_user!

  respond_to :html

  # def index
  #   @companies = Company.all
  #   respond_with(@companies)
  # end

  def show
  end

  # def new
  #   @company = Company.new
  #   respond_with(@company)
  # end

  def edit
  end

  # def create
  #   @company = Company.new(company_params)
  #   @company.save
  #   respond_with(@company)
  # end

  def update
    @company.update(company_params)
    respond_with(@company)
  end

  # def destroy
  #   @company.destroy
  #   respond_with(@company)
  # end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :email, :fax, :sending_telephone, :location_name, :address, :receiving_telephone, :receiving_agent)
    end
end
