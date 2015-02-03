require 'doc_raptor'
require 'phaxio'

class FAXMailer < ActionMailer::Base
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::TextHelper

  default from: current_user.email

  def send_fax(fax, current_user)

		#create instance variables
		@recipient_name = fax.recipient_name
    @company_name = current_user.company
    @fax_number = fax.fax_number
    @subject = fax.subject
    @content = fax.content

  	#create PDFS
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
.fax label {
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
          <div class="purchaseorder-from">
            <div class="section"><div class="text-label">From</div>' + From: @company_name + '<br>' + current_user.email + '</div>
            <div class="section"><div class="text-label">Sent By</div>' + current_user.first_name + ' ' + current_user.last_name + '</div>
          </div>
        </div>
        <div class="purchaseorder-vendor clear">
          <div class="to">
            <div class="text-label">'To'</div>
          </div>
          <div class="vendor-select">' + @recipient_name'</div>
          <div class="date-required">
            <div class="text-label">Date Required</div>
            <div class="date-field">' + @fax_number + '</div>
          </div>
          <div class="date-required">
            <div class="text-label">Date Required</div>
            <div class="date-field">' + Date: Date.now Time: Time.now + '</div>
          </div>
        </div>
        <div class="purchaseorder-description">
          <div class="text-label">'@subject'</div>
        </div>
        <div class="purchaseorder-description">
          <div class="text-label"><p>'@content'</p></div>
        </div>
      </div>
</body>
</html>'
		#randomly generate file name so we don't have file name collisions
		file_name = [*100000..999999].sample.to_s
    
    if Rails.env == 'production' || Rails.env == 'staging' then
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

		#send fax
    @sent_fax = Phaxio.send_fax(to: fax.number.to_s, filename: File.new(file_name + ".pdf"))
    Phaxio.get_fax_status(id: @sent_fax["faxId"])
	end


end
