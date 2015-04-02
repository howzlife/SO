class AddressesController < ApplicationController
  before_action :set_address, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /addresses.json
  def index
    if params["q"].blank?
      @addresses = @company.addresses.all.page params[:page]
    else
      @addresses = @company.addresses.search(@company.id, params["q"]).page params[:page]
    end
  end

  def new
    @address = @company.addresses.new
  end

  # POST /addresses
  # POST /addresses.json
  def create
    @address = @company.addresses.build(address_params) 

    respond_to do |format|
      if @address.save
        # If this is first address, set as bill and ship address
        @company.billaddress ||= @address.id
        @company.shipaddress ||= @address.id
        @company.save!

        format.html { redirect_to edit_company_path(@company), notice: 'Address was successfully created.' }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

	def edit
    @address = @company.addresses.find(params[:id])
  end

  # PATCH/PUT /addresses/1
  # PATCH/PUT /addresses/1.json
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to edit_company_path(@company), notice: 'Address was successfully updated.' }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1
  # DELETE /addresses/1.json
  def destroy
    @address.destroy
    respond_to do |format|
      format.html { redirect_to edit_company_path(@company), notice: 'Address was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = @company.addresses.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
      #funky strong params block taken from https://github.com/rails/rails/issues/9454#issuecomment-14167664
      params.require(:address).permit(:id, :name, :address, :telephone, :agent).tap do |whitelisted|
        whitelisted[:address] = params[:address][:address]
      end
    end
end
