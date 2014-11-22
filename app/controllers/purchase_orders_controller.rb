class PurchaseOrdersController < ApplicationController
  require 'send_pdf'
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :has_company_info, only: [:new]
  include ActionView::Helpers::NumberHelper

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    if params["q"].blank? && params["status"].blank? 
      @purchase_orders = @company.purchase_orders.all
    else
    	if params["q"].blank?
	      @purchase_orders = PurchaseOrder.status(@company.id, params["status"])
	    else
	      @purchase_orders = PurchaseOrder.search(@company.id, params["q"])
	    end
    end
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
  end

  # GET /purchase_orders/new
  def new
    @purchase_order = @company.purchase_orders.new
    @vendors = @company.vendors.all
  end

  # GET /purchase_orders/1/edit
  def edit
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    @pop = purchase_order_params

    #get vendor name so we can search for it.
    vendor_name = purchase_order_params["vendor"]

    #.find_by_name is a custom instance method I put in the company controller...
    #We're also removing attributes here from the company vendor that we don't want to save to the ...
    #new PO vendor we are about to save
    vendor = @company.vendors.find(vendor_name).attributes.except("_id","deleted_at","updated_at","created_at")
    @pop["vendor"] = vendor

    #The vendor data had to be passed as a string. Here were are changing it to a hash so it can be saved.
    #desired_vendor_hash = JSON.parse(@pop["vendor"].gsub("'",'"').gsub('=>',':'))
    #@pop["vendor"] = JSON.parse(@pop["vendor"].gsub("'",'"').gsub('=>',':'))
		@pop["deliver_to"] = JSON.parse(@pop["deliver_to"].gsub("'",'"').gsub('=>',':'))
	
    @purchase_order = @company.purchase_orders.build(@pop)

    respond_to do |format|
      if @purchase_order.save
        #send pdf
        PDFMailer.send_pdf(@purchase_order, current_user.company.email).deliver

        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      # It's mandatory to specify the nested attributes that should be whitelisted.
      # If you use `permit` with just the key that points to the nested attributes hash,
      # it will return an empty hash.
      params.require(:purchase_order).permit(:number, :status, :description, :tags, :comment, :date_required, :deliver_to, :vendor, vendors_attributes: [:name, :email, :contact, :telephone])
    end

    def has_company_info
      if @company.addresses.first.try(:name) && @company.try(:email) && @company.try(:prefix) && @company.addresses.first.try(:address) && @company.vendors.first.try(:name) && @company.vendors.first.try(:email)
      
      else 
        flash[:notice] = "Fill in required Company information and have at least one Vendor before making a PO"
        redirect_to :back
      end
    end
end
