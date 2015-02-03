require "rails_helper"

RSpec.describe FaxesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/faxes").to route_to("faxes#index")
    end

    it "routes to #new" do
      expect(:get => "/faxes/new").to route_to("faxes#new")
    end

    it "routes to #show" do
      expect(:get => "/faxes/1").to route_to("faxes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/faxes/1/edit").to route_to("faxes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/faxes").to route_to("faxes#create")
    end

    it "routes to #update" do
      expect(:put => "/faxes/1").to route_to("faxes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/faxes/1").to route_to("faxes#destroy", :id => "1")
    end

  end
end
