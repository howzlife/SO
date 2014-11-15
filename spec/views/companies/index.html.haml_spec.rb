require 'rails_helper'

RSpec.describe "companies/index", :type => :view do
  before(:each) do
    assign(:companies, [
      Company.create!(
        :name => "Name",
        :email => "Email",
        :send_fax => 1,
        :send_telephone => 2,
        :location_name => "Location Name",
        :address => "Address",
        :receive_telephone => 3,
        :receiving_agent => "Receiving Agent"
      ),
      Company.create!(
        :name => "Name",
        :email => "Email",
        :send_fax => 1,
        :send_telephone => 2,
        :location_name => "Location Name",
        :address => "Address",
        :receive_telephone => 3,
        :receiving_agent => "Receiving Agent"
      )
    ])
  end

  it "renders a list of companies" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Location Name".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Receiving Agent".to_s, :count => 2
  end
end
