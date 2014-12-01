class PurchaseOrdersController < ApplicationController
  require 'send_pdf'
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :has_company_info, only: [:new]
  include ActionView::Helpers::NumberHelper

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    if params["q"].blank? && params["status"].blank? && params["label"].blank? && params["archived"].blank? 
      @purchase_orders = @company.purchase_orders.active.page params[:page]
    else
    	if params.has_key?("status")
	      @purchase_orders = PurchaseOrder.status(@company.id, params["status"]).page params[:page]
	    elsif params.has_key?("label")
	      @purchase_orders = PurchaseOrder.label(@company.id, params["label"]).page params[:page]
      elsif params.has_key?("archived")
        @purchase_orders = PurchaseOrder.archived(@company.id).page params[:page]
      elsif params.has_key?("q")
        @purchase_orders = PurchaseOrder.search(@company.id, params["q"]).page params[:page]
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
    if @purchase_order.status != "draft"
      redirect_to action: "index"
    end
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    @pop = organize_purchase_order_params(purchase_order_params)	
    @purchase_order = @company.purchase_orders.build(@pop)
    @purchase_order.status = "draft"
    @company.labels.find_or_create_by(name: @purchase_order.label)

    respond_to do |format|
      if @purchase_order.save
        #send pdf
        if params[:status] == "email"
          PDFMailer.send_pdf(@purchase_order, current_user.company.email).deliver
          @purchase_order.status = "open"
          @purchase_order.save

          format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully emailed.' }
          format.json { render :show, status: :created, location: @purchase_order }
        else
          format.html { redirect_to edit_purchase_order_path(@purchase_order), notice: 'Purchase order was successfully saved.' }
          format.json { render :edit, status: :created, location: edit_purchase_order_path(@purchase_order) }
        end

      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    #send pdf
    if params[:status] == "email"
      PDFMailer.send_pdf(@purchase_order, current_user.company.email).deliver
      @purchase_order.status = "open"
    elsif params[:status] == "closed"
      @purchase_order.status = "closed"
    elsif params[:status] == "open"
      @purchase_order.status = "open"
    elsif params[:status] == "draft" 
      @pop = organize_purchase_order_params(purchase_order_params) 
      @purchase_order.update(@pop.except(:number))
      @company.labels.find_or_create_by(name: @purchase_order.label)
    elsif params[:archived] == "true"
      @purchase_order.archived = true
    end

    respond_to do |format|
      if @purchase_order.save
        if @purchase_order.status == "draft"
          format.html { redirect_to edit_purchase_order_path(@purchase_order), notice: 'Purchase order was successfully saved.' }
          format.json { render :edit, status: :created, location: edit_purchase_order_path(@purchase_order) }
        elsif params[:status] == "email"                   
          format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully emailed.' }
          format.json { render :show, status: :ok, location: @purchase_order }          
        else         
          format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
          format.json { render :show, status: :ok, location: @purchase_order }
        end
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    if @purchase_order.status == "draft"
      @purchase_order.destroy
      respond_to do |format|
        format.html { redirect_to purchase_orders_path, notice: 'Purchase order was successfully deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @purchase_order, notice: 'Purchase order can\' be deleted.' }
        format.json { head :no_content }
      end
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
      params.require(:purchase_order).permit(:number, :status, :description, :tags, :archived, :label, :comment, :date_required, :address, :vendor)
    end

    def has_company_info
      if @company.addresses.first.try(:name) && @company.try(:email) && @company.try(:prefix) && @company.addresses.first.try(:address) && @company.vendors.first.try(:name) && @company.vendors.first.try(:email)
      
      else 
        flash[:notice] = "Fill in required Company information and have at least one Vendor before making a PO"
        redirect_to :back
      end
    end

    def organize_purchase_order_params(purchase_order_params)

      #get vendor name so we can search for it.
      vendor_id = purchase_order_params["vendor"]
      #get company address so we can search for it.
      company_address_id = purchase_order_params["address"]

      #We're also removing attributes here from the company vendor that we don't want to save to the ...
      #new PO vendor we are about to save
      vendor = @company.vendors.find(vendor_id).attributes.except("_id","deleted_at","updated_at","created_at") rescue nil
      purchase_order_params["vendor"] = vendor

      #We're also removing attributes here from the company address that we don't want to save to the ...
      #new PO vendor we are about to save
      address = @company.addresses.find(company_address_id).attributes.except("_id","deleted_at","updated_at","created_at") rescue nil
      purchase_order_params["address"] = address

      return purchase_order_params
    end
end
