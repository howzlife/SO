class FaxesController < ApplicationController
  before_action :set_fax, only: [:show, :edit, :update, :destroy]

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
    @number = 
    respond_to do |format|
      if @fax.save
          if params[:send] 
            @sent_fax = Phaxio.send_fax(to: '(+1 613 563 4984)', string_data: "Hi Ryan, Greetings from SwiftOrders")
            if @sent_fax["success"]  
              format.html { redirect_to faxes_url, notice: @sent_fax["message"] }
              #format.json { redirect_to faxes_path, notice: @sent_fax["message"] }
            else 
              format.html {redirect_to faxes_url, notice: @sent_fax["message"]}
              format.json { render :show, status: :created, location: @fax }
            end
          elsif params[:draft]
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
      params.require(:fax).permit(:recipient_name, :company_name, :fax_number, :subject, :content)
    end

end
