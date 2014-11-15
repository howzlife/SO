require 'rails_helper'

RSpec.describe "companies/show", :type => :view do
  before(:each) do
    @company = assign(:company, Company.create!(
      :name => "Name",
      :email => "Email",
      :send_fax => 1,
      :send_telephone => 2,
      :location_name => "Location Name",
      :address => "Address",
      :receive_telephone => 3,
      :receiving_agent => "Receiving Agent"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Location Name/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Receiving Agent/)
  end
end
