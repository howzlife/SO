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
    if params.has_key?("send")
      @fax = Phaxio.send_fax(to: '15555555555', string_data: "hello world")
      if @fax["success"]
        self.recipient_name = "success"
        redirect_to faxes_path, notice: @fax["message"]
      end
    end
    respond_with(@fax)
  end

  def edit
  end

  def create
    @fax = Fax.new(fax_params)
    @fax.save
    respond_with(@fax)
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
