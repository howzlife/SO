require 'rails_helper'

RSpec.describe "purchase_orders/edit", :type => :view do
  before(:each) do
    @purchase_order = assign(:purchase_order, PurchaseOrder.create!(
      :number => "",
      :status => "MyString",
      :description => "MyString",
      :purchasing_agent => "MyString"
    ))
  end

  it "renders the edit purchase_order form" do
    render

    assert_select "form[action=?][method=?]", purchase_order_path(@purchase_order), "post" do

      assert_select "input#purchase_order_number[name=?]", "purchase_order[number]"

      assert_select "input#purchase_order_status[name=?]", "purchase_order[status]"

      assert_select "input#purchase_order_description[name=?]", "purchase_order[description]"

      assert_select "input#purchase_order_purchasing_agent[name=?]", "purchase_order[purchasing_agent]"
    end
  end
end
