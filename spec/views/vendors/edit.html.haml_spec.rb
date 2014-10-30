require 'rails_helper'

RSpec.describe "vendors/edit", :type => :view do
  before(:each) do
    @vendor = assign(:vendor, Vendor.create!(
      :name => "MyString",
      :address => "MyString",
      :telephone => "MyString"
    ))
  end

  it "renders the edit vendor form" do
    render

    assert_select "form[action=?][method=?]", vendor_path(@vendor), "post" do

      assert_select "input#vendor_name[name=?]", "vendor[name]"

      assert_select "input#vendor_address[name=?]", "vendor[address]"

      assert_select "input#vendor_telephone[name=?]", "vendor[telephone]"
    end
  end
end
