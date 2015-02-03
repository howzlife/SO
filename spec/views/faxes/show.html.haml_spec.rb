require 'rails_helper'

RSpec.describe "faxes/show", :type => :view do
  before(:each) do
    @fax = assign(:fax, Fax.create!(
      :recipient_name => "Recipient Name",
      :company_name => "Company Name",
      :fax_number => "Fax Number",
      :subject => "Subject",
      :content => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Recipient Name/)
    expect(rendered).to match(/Company Name/)
    expect(rendered).to match(/Fax Number/)
    expect(rendered).to match(/Subject/)
    expect(rendered).to match(/MyText/)
  end
end
