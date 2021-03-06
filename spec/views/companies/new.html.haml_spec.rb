require 'rails_helper'

RSpec.describe "companies/new", :type => :view do
  before(:each) do
    assign(:company, Company.new(
      :name => "MyString",
      :email => "MyString",
      :send_fax => 1,
      :send_telephone => 1,
      :location_name => "MyString",
      :address => "MyString",
      :receive_telephone => 1,
      :receiving_agent => "MyString"
    ))
  end

  it "renders new company form" do
    render

    assert_select "form[action=?][method=?]", companies_path, "post" do

      assert_select "input#company_name[name=?]", "company[name]"

      assert_select "input#company_email[name=?]", "company[email]"

      assert_select "input#company_send_fax[name=?]", "company[send_fax]"

      assert_select "input#company_send_telephone[name=?]", "company[send_telephone]"

      assert_select "input#company_location_name[name=?]", "company[location_name]"

      assert_select "input#company_address[name=?]", "company[address]"

      assert_select "input#company_receive_telephone[name=?]", "company[receive_telephone]"

      assert_select "input#company_receiving_agent[name=?]", "company[receiving_agent]"
    end
  end
end
