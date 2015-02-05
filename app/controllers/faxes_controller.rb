class FaxesController < ApplicationController
  before_action :set_fax, only: [:show, :edit, :update, :destroy]
  require 'fax_mailer'

  respond_to :html

  def index
    @faxes = Fax.all
    respond_with(@faxes)
  end

  def show
    respond_with(@fax)
  end

  def new
    @fax = Fax.new
    respond_with(@fax)
  end

  def edit
  end

  def create
    @fax = Fax.new(fax_params)
    @recipient = @fax.recipient_name
    @number =  ("+1" + @fax.fax_number.to_s.gsub(/[^0-9]/, "")).to_s
    @fax[:status] = "draft"

    respond_to do |format|
      if @fax.save
          if params[:send]
            pdf_html, pdf_file = FAXMailer.save_pdf(@fax, current_user) 
            @sent_fax = Phaxio.send_fax(to: @number, string_data: pdf_html, string_data_type: 'html')

            if @sent_fax["success"]
              @fax.update_attribute(:status, "sent") 
              format.html { redirect_to faxes_url, notice: @sent_fax["message"] }
            else 
              @fax.update_attribute(status, "drafted")  
              format.html {redirect_to faxes_url, notice: @sent_fax["message"]}
              format.json { render :show, status: :created, location: @fax }
            end

          elsif params[:draft]
            params[:status] = "draft"
            format.html { redirect_to faxes_url, notice: "Fax saved as draft" }
            format.json { render json: @fax.errors, status: :unprocessable_entity }
          end
      end
    end
  end

  def update
    @fax.update(fax_params)
    respond_with(@fax)
  end

  def destroy
    @fax.destroy
    respond_with(@fax)
  end

  private
    def set_fax
      @fax = Fax.find(params[:id])
    end

    def fax_params
      params.require(:fax).permit(:recipient_name, :company_name, :fax_number, :subject, :content, :status)
    end

end
