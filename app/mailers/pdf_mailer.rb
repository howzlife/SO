require 'doc_raptor'
DocRaptor.api_key "ydVvQdh5knSYuG8yZkS"

class PDFMailer < ActionMailer::Base
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::TextHelper

  default from: "from@example.com"

  def send_pdf(purchase_order, company, current_user)

		#create instance variables
		@purchaComse_order = purchase_order
    @company = company

		ponumber = @purchase_order.number
		a = @purchase_order.address

  	#create PDFS
    byebug
	  pdf_html = '<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <style type="text/css">
    @page {
    	margin: 30px; background: #ffffff;
			@bottom { 
          content: "SwiftOrders takes the pain out of business purchasing. • SwiftOrders.com • Try it free for 60 days.";
          font-size: 7px; color: #3895d9; font-family: sans-serif;
        }
    }
.clear:after {
content: ".";
display: block;
clear: both;
visibility: hidden;
line-height: 0;
height: 0;
}
.card {
font-family: sans-serif;
font-size: 11px;
}
.card .text-label {
  font-size: 10px;
  color: #a1a8c2;
  font-weight: 400;
}
.card h4 {
  font-size: 12px;
  font-weight: 600;
  margin: 0 0 10px 0;
}
.purchaseorder label {
  display: none;
}

.purchaseorder .purchaseorder-vendor,
.purchaseorder .purchaseorder-deliverto {
    border-bottom: 1px solid #dedfe3;
    padding: 15px 0;
}

.purchaseorder .purchaseorder-vendor .to,
.purchaseorder .purchaseorder-vendor .date-required, .purchaseorder .purchaseorder-deliverto .to,
.purchaseorder .purchaseorder-deliverto .date-required {
    float: left;
}

.purchaseorder .purchaseorder-vendor .to .text-label,
.purchaseorder .purchaseorder-vendor .date-required .text-label,
.purchaseorder .purchaseorder-deliverto .to .text-label,
.purchaseorder .purchaseorder-deliverto .date-required .text-label {
    font-size: 14px;
    color: #a1a8c2;
    font-weight: 600;
}

.purchaseorder .purchaseorder-vendor .to,
.purchaseorder .purchaseorder-deliverto .to {
    float: left;
    margin: 0 10px 0 0;
}

.purchaseorder .purchaseorder-vendor .date-required,
.purchaseorder .purchaseorder-deliverto .date-required {
    min-width: 225px;
    float: right;
    padding-left: 25px;
    border-left: 1px solid #dedfe3;
}

.purchaseorder .purchaseorder-vendor .vendor-select,
.purchaseorder .purchaseorder-vendor .deliverto-select,
.purchaseorder .purchaseorder-vendor .deliverto-agent, .purchaseorder .purchaseorder-deliverto .vendor-select,
.purchaseorder .purchaseorder-deliverto .deliverto-select,
.purchaseorder .purchaseorder-deliverto .deliverto-agent {
    float: left;
}

.purchaseorder .purchaseorder-vendor .deliverto-select,
.purchaseorder .purchaseorder-deliverto .deliverto-select {
    margin: 0 25px 0 0;
}

.purchaseorder .purchaseorder-description {
    margin: 5px 0;
}

.purchaseorder .purchaseorder-description .text-label {
    font-size: 14px;
    color: #a1a8c2;
    font-weight: 600;
}

.purchaseorder .purchaseorder-input {
    min-height: 215px;
}

.purchaseorder .purchaseorder-input p {
    margin: 0 0 21px 0;
}

.purchaseorder .purchaseorder-header {
    border-bottom: 1px solid #dedfe3;
    padding: 0px 0 15px 0;
}

.purchaseorder .purchaseorder-header .purchaseorder-company {
    font-size: 14px;
    font-weight: 600;
}

.purchaseorder .purchaseorder-header .purchaseorder-company,
.purchaseorder .purchaseorder-header .purchaseorder-address {
    float: left;
}

.purchaseorder .purchaseorder-header .purchaseorder-address {
    margin: 0 0 0 25px;
}

.purchaseorder .purchaseorder-header .purchaseorder-number {
    float: right;
    margin: 0 25px 0 0;
}

.purchaseorder .purchaseorder-header .purchaseorder-number .number, .purchaseorder .date-required .date-field {
    color: #ea4e1b;
    font-size: 14px;
}

.purchaseorder .purchaseorder-header .purchaseorder-number .date {
    color: #a1a8c2;
}

.purchaseorder .purchaseorder-header .purchaseorder-from {
    float: right;
    font-style: normal;
    color: #a1a8c2;
    min-width: 225px;
    font-size: 12px;
    padding-left: 25px;
    border-left: 1px solid #dedfe3;
}

.purchaseorder .purchaseorder-header .section {
    margin: 10px 0 0 0;
}



    </style>
</head>
<body>
	<div class="card purchaseorder clear" id="purchaseorder">
        <div class="purchaseorder-header clear">
          <div class="purchaseorder-company">' + @company.name + '</div>
          <div class="purchaseorder-address">' + @company.name + '<br>' + @company.email + '</div>
          <div class="purchaseorder-from">
            <div class="section"><div class="text-label">From</div>' + @company.name + '<br>' + @company.email + '</div>
            <div class="section"><div class="text-label">Sent By</div>' + current_user.first_name + ' ' + current_user.last_name + '</div>
          </div>
          <div class="purchaseorder-number">
            <div class="text-label">Purchase Order</div>
            <div class="number">'+ponumber+'</div>
            <div class="section">
              <div class="text-label">Date</div>
              <div class="date">'+@purchase_order.date.strftime("%B #{@purchase_order.date.day.ordinalize}, %Y")+'</div>
            </div>
          </div>
        </div>
        <div class="purchaseorder-vendor clear">
          <div class="to">
            <div class="text-label">To</div>
          </div>
          <div class="vendor-select">' + @purchase_order.vendor.name + '<br>Attention: '+@purchase_order.vendor.contact+'<br>' + @purchase_order.vendor.email + '</div>
          <div class="date-required">
            <div class="text-label">Date Required</div>
            <div class="date-field">' + @purchase_order.date_required + '</div>
          </div>
        </div>
        <div class="purchaseorder-description">
          <div class="text-label">Description</div>
        </div>
        <div class="purchaseorder-input">'+simple_format(@purchase_order.description)+'</div>
        <div class="purchaseorder-deliverto clear">
          <div class="to">
            <div class="text-label">Ship To</div>
          </div>
          <div class="deliverto-select">' + a["name"] + '<br>' + a["address"]["address_line_1"] + '<br>' + a["address"]["address_line_2"] + '<br>' + a["address"]["city"] + ', ' + a["address"]["state"] + ', ' + a["address"]["zip"] + '<br>Tel. ' + a["telephone"] + '</div>
          <div class="to">
            <div class="text-label">Attention</div>
          </div>
          <div class="deliverto-agent">' + a["agent"] + '</div>
        </div>
      </div>
</body>
</html>'
		#randomly generate file name so we don't have file name collisions
		file_name = [*100000..999999].sample.to_s
    
    if Rails.env == 'production' then
  		File.open(file_name, "w+b") do |f|
  		  f.write DocRaptor.create(:document_content => pdf_html,
  		                           :name             => file_name,
  		                           :document_type    => "pdf",
  		                           :test             => false)
  		end
    else
      File.open(file_name, "w+b") do |f|
        f.write DocRaptor.create(:document_content => pdf_html,
                                 :name             => file_name,
                                 :document_type    => "pdf",
                                 :test             => true)
      end
    end

		#add attachment, renamed
		attachments['purchase_order_'+@purchase_order.number.to_s+'.pdf'] = File.read(file_name)
		#send email with pdf 
		mail(to: @purchase_order.vendor.email, subject: 'Purchase Order '+@purchase_order.number.to_s, from: @company.email, reply_to: @company.email)
		#delete local file
		File.delete(file_name)
	end


end
