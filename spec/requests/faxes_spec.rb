require 'rails_helper'

RSpec.describe "Faxes", :type => :request do
  describe "GET /faxes" do
    it "works! (now write some real specs)" do
      get faxes_path
      expect(response).to have_http_status(200)
    end
  end
end
