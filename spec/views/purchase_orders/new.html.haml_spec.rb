require 'rails_helper'

RSpec.describe "purchase_orders/new", :type => :view do
  before(:each) do
    assign(:purchase_order, PurchaseOrder.new(
      :number => "",
      :status => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new purchase_order form" do
    render

    assert_select "form[action=?][method=?]", purchase_orders_path, "post" do

      assert_select "input#purchase_order_number[name=?]", "purchase_order[number]"

      assert_select "input#purchase_order_status[name=?]", "purchase_order[status]"

      assert_select "input#purchase_order_description[name=?]", "purchase_order[description]"
    end
  end
end
