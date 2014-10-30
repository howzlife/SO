require 'rails_helper'

RSpec.describe "purchase_orders/index", :type => :view do
  before(:each) do
    assign(:purchase_orders, [
      PurchaseOrder.create!(
        :number => "",
        :status => "Status",
        :description => "Description",
        :purchasing_agent => "Purchasing Agent"
      ),
      PurchaseOrder.create!(
        :number => "",
        :status => "Status",
        :description => "Description",
        :purchasing_agent => "Purchasing Agent"
      )
    ])
  end

  it "renders a list of purchase_orders" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Purchasing Agent".to_s, :count => 2
  end
end
