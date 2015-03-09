class PurchaseOrdersController < ApplicationController
  require 'pdf_mailer'
  require 'format_po_fax'
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy]
  before_action :has_company_info, only: [:new]
  before_action :authenticate_user!
  respond_to :html, :json
  responders :flash
  include ActionView::Helpers::NumberHelper
  include ActionController::Base::PurchaseOrdersHelper

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @company = current_user.company
    if params["q"].blank? && params["status"].blank? && params["label"].blank? && params["archived"].blank? 
      @purchase_orders = @company.purchase_orders.active.page params[:page]
    else
    	if params.has_key?("status")
	      @purchase_orders = PurchaseOrder.status(@company.id, params["status"]).page params[:page]
	    elsif params.has_key?("label")
	      @purchase_orders = PurchaseOrder.label(@company.id, params["label"]).page params[:page]
      elsif params.has_key?("archived")
        @purchase_orders = PurchaseOrder.archived(@company.id).page params[:page]
      elsif params.has_key?("was_deleted")
        @purchase_orders = PurchaseOrder.was_deleted(@company.id).page params[:page]
      elsif params.has_key?("q")
        @purchase_orders = PurchaseOrder.search(@company.id, params["q"]).page params[:page]
	    end
    end
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    if @purchase_order.status == "draft"
      render :action => "edit"
    end
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
  #NOTE - This action is only accessible from the Create New PO location. All others are in the UPDATE action. "
  def create
    @pop = organize_purchase_order_params(purchase_order_params)	
    @purchase_order = @company.purchase_orders.build(@pop)
    @company.labels.find_or_create_by(name: @purchase_order.label)
    @purchase_order.status = "draft"
    @purchase_order.save

        ## Response for send by Fax or Email 
        if params[:status] == "email"
     			PDFMailer.send_pdf(@purchase_order, @company, current_user).deliver
          @purchase_order.status = "open"
          flash[:notice] = 'Success, your PO has been sent by Email.' if @purchase_order.save
          respond_with(@purchase_order)
        elsif params[:status] == "fax"
          @sent_fax = send_po_fax(@purchase_order) 
          # If fax was successful, we get a successful response. 
          if @sent_fax["success"]
            @purchase_order.update_attribute(:status, "open")
            flash[:notice] = 'Success, your PO has been sent by fax.' 
            respond_with(@purchase_order)
            # Otherwise, we get an error message. 
          else 
            respond_to do |format|
              format.html {render :new, notice: @sent_fax["message"]}
              format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
            end
          end

        #State transitions without send -> Mark as Open, Save as Draft
        elsif params[:status] == "open"
          @purchase_order.status = "open"
          flash[:notice] = 'Success, your PO has been Opened.' if @purchase_order.save
          respond_with(@purchase_order)

        elsif params[:status] == "draft"
          @purchase_order.status = "draft" 
          flash[:notice] = 'Success, your PO has been saved as draft.' if @purchase_order.save
          respond_with(@purchase_order)

        elsif params[:status] == "print"
           @purchase_order.status = "draft" 
           @purchase_order.save
           respond_with(@purchase_order)
        # Error Handling
        else
          respond_to do |format|
            format.html { render :new }
            format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
          end
        end
  end


  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    
    #Email and Fax actions, to actually resend the information
    if params[:status] == "email"
      PDFMailer.send_pdf(@purchase_order, @company, current_user).deliver
      @purchase_order.update_attribute(:status, "open")   
      flash[:notice] = "Success, your PO has been sent by Email." if @purchase_order.save
      respond_with(@purchase_order)  

    elsif params[:status] == "fax"
      @sent_fax = send_po_fax(@purchase_order)
      @successful_send = @sent_fax["success"]
      if @successful_send
        @purchase_order.update_attribute(:status, "open")
        flash[:notice] = "Success, your PO has been sent by Fax." if @purchase_order.save 
        @purchase_order.save
        respond_with(@purchase_order)
      else 
        flash[:notice] = @sent_fax["message"]
        respond_with(@purchase_order)
      end 

    #State transitions - Open, Closed, Cancelled, Deleted, Draft, Archived

    elsif params[:status] == "open"
      @purchase_order.update_attribute(:status, "open")
      flash[:notice] = "Purchase Order was successfully Saved." if @purchase_order.save
      respond_with(@purchase_order)

    elsif params[:status] == "save"
      @pop = organize_purchase_order_params(purchase_order_params)  
      @updated_po = @company.purchase_orders.build(@pop)
      @company.labels.find_or_create_by(name: @purchase_order.label)
      @purchase_order.destroy!
      @purchase_order = @updated_po
      @purchase_order.status = "draft"
      @purchase_order.save
      flash[:notice] = 'Success, your PO has been saved as draft' if @purchase_order.save
      respond_with(@purchase_order)

    elsif params[:status] == "cancel_changes"
      flash[:notice] = "Changes have been discarded."
      respond_with(@purchase_order)

    elsif params[:status] == "closed"
      @purchase_order.update_attribute(:status, "closed") 
      flash[:notice] = "Purchase Order has been Closed." if @purchase_order.save
      respond_with(@purchase_order)
    elsif params[:status] == "cancelled"
      @purchase_order.update_attribute(:status, "cancelled")
      flash[:notice] = "Purchase Order has been Cancelled" if @purchase_order.save
      respond_to do |format|
        format.html { redirect_to purchase_orders_path }
      end

      # stowaway methods - archive, delete, and undo archive, undo delete
    elsif params[:status] == "deleted"
      @purchase_order.update_attribute(:was_deleted, true)
      flash[:notice] = "Purchase Order has been Deleted." if @purchase_order.save
      respond_to do |format|
        format.html { redirect_to purchase_orders_path }
        format.json
      end
    elsif params[:status] == "undelete"
      @purchase_order.update_attribute(:was_deleted, false)
      flash[:notice] = "Purchase Order has been Un-Deleted." if @purchase_order.save
      respond_with(@purchase_order)
    elsif params[:status] == "archive"
      @purchase_order.update_attribute(:archived, true)
      flash[:notice] = "Purchase Order has been Archived." if @purchase_order.save
      respond_with(@purchase_order)

    elsif params[:status] == "unarchive"
      @purchase_order.update_attribute(:archived, false)
      flash[:notice] = "Purchase order has been Un-Archived." if @purchase_order.save
      respond_with(@purchase_order)

    elsif params[:status] == "print"
      respond_with(@purchase_order)

    elsif params[:status] == "duplicate"
      @po = @company.purchase_orders.new
      @po.status = "draft"
      @po.description = @purchase_order.read_attribute(:description)
      @po.vendor = @purchase_order.read_attribute(:vendor)
      @po.number = generate_po_number
      @po.address = @purchase_order.read_attribute(:address)
      @po.update_attribute(:date_required, "ASAP")
      @po.label = @purchase_order.read_attribute(:label)
      @purchase_order = @po
      flash[:notice] = "Purchase Order Duplicated as New" if @purchase_order.save
      respond_with(@purchase_order)
      # @new_po = @company.purchase_orders.new
      # @new_po.write_attribute(:vendor, @purchase_order.read_attribute(:vendor))
      # @new_po.write_attribute(:address, @purchase_order.read_attribute(:address))
      # @purchase_order = @company.purchase_orders.build(@new_po)
      # @company.labels.find_or_create_by(name: @purchase_order.label)
      # @purchase_order.status = "draft"
      # flash[:notice] = "Purchase Order was duplicated as new." if @purchase_order.save
      # respond_with(@purchase_order)
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
        format.html { redirect_to @purchase_order, notice: 'Purchase order can\'t be deleted.' }
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
      
      elsif !@company.addresses.first.try(:name)
        flash[:notice] = "Please fill in company address information"
        #redirect_to :back
        redirect_to new_address_path
      elsif !@company.vendors.first.try(:name)
        flash[:notice] = "Please have at least one Vendor before making a PO"
        redirect_to new_vendor_path
      elsif !@company.try(:prefix)
        flash[:notice] = "Please fill in prefix information"
        redirect_to settings_path
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
    def generate_po_number
      @company.read_attribute(:prefix) + ".#{Random.rand(100..999)}.#{Random.rand(100..999)}" 
    end
end
