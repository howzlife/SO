require 'rails_helper'

RSpec.describe "faxes/new", :type => :view do
  before(:each) do
    assign(:fax, Fax.new(
      :recipient_name => "MyString",
      :company_name => "MyString",
      :fax_number => "MyString",
      :subject => "MyString",
      :content => "MyText"
    ))
  end

  it "renders new fax form" do
    render

    assert_select "form[action=?][method=?]", faxes_path, "post" do

      assert_select "input#fax_recipient_name[name=?]", "fax[recipient_name]"

      assert_select "input#fax_company_name[name=?]", "fax[company_name]"

      assert_select "input#fax_fax_number[name=?]", "fax[fax_number]"

      assert_select "input#fax_subject[name=?]", "fax[subject]"

      assert_select "textarea#fax_content[name=?]", "fax[content]"
    end
  end
end
