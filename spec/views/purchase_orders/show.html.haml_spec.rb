require 'rails_helper'

RSpec.describe "purchase_orders/show", :type => :view do
  before(:each) do
    @purchase_order = assign(:purchase_order, PurchaseOrder.create!(
      :number => "",
      :status => "Status",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Purchasing Agent/)
  end
end
