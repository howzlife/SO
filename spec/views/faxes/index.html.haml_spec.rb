require 'rails_helper'

RSpec.describe "faxes/index", :type => :view do
  before(:each) do
    assign(:faxes, [
      Fax.create!(
        :recipient_name => "Recipient Name",
        :company_name => "Company Name",
        :fax_number => "Fax Number",
        :subject => "Subject",
        :content => "MyText"
      ),
      Fax.create!(
        :recipient_name => "Recipient Name",
        :company_name => "Company Name",
        :fax_number => "Fax Number",
        :subject => "Subject",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of faxes" do
    render
    assert_select "tr>td", :text => "Recipient Name".to_s, :count => 2
    assert_select "tr>td", :text => "Company Name".to_s, :count => 2
    assert_select "tr>td", :text => "Fax Number".to_s, :count => 2
    assert_select "tr>td", :text => "Subject".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
