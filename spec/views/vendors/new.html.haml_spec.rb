require 'rails_helper'

RSpec.describe "vendors/new", :type => :view do
  before(:each) do
    assign(:vendor, Vendor.new(
      :name => "MyString",
      :address => "MyString",
      :telephone => "MyString"
    ))
  end

  it "renders new vendor form" do
    render

    assert_select "form[action=?][method=?]", vendors_path, "post" do

      assert_select "input#vendor_name[name=?]", "vendor[name]"

      assert_select "input#vendor_address[name=?]", "vendor[address]"

      assert_select "input#vendor_telephone[name=?]", "vendor[telephone]"
    end
  end
end
