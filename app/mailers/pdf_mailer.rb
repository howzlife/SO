require 'doc_raptor'

class PDFMailer < ActionMailer::Base
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::TextHelper

  default from: "from@example.com"

  def send_pdf(purchase_order)

		#create instance variables
		@purchase_order = purchase_order

		ponumber = 'EMP.' + number_with_delimiter(@purchase_order.number, :delimiter => '.')


  	#create PDFS
	  pdf_html = '<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <style type="text/css">
    @page { margin: 30px; background: #ffffff; }
.clear:after {
content: ".";
display: block;
clear: both;
visibility: hidden;
line-height: 0;
height: 0;
}
.card {
  background: #ffffff;
font-family: "proxima-nova", sans-serif;
font-size: 15px;
  padding: 25px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  outline: none;
  border: 1px solid #e7e7e7;
  border-radius: 4px;
}
.card .text-label {
  font-size: 12px;
  color: #a1a8c2;
  font-weight: 400;
}
.card h4 {
  font-size: 14px;
  font-weight: 600;
  margin: 0 0 10px 0;
}
.purcuahseorder label {
  display: none;
}
.purcuahseorder .purcuahseorder-vendor {
  border-bottom: 1px solid #dedfe3;
  padding: 15px 0;
}
.purcuahseorder .purcuahseorder-vendor .to {
  font-size: 18px;
  color: #a1a8c2;
  font-weight: 600;
  float: left;
  margin: 0 10px 0 0;
}
.purcuahseorder .purcuahseorder-vendor .vendor-select {
  float: left;
}
.purcuahseorder .purcuahseorder-input {
  min-height: 315px;
  background: url(/assets/line.png);
}
.purcuahseorder .purcuahseorder-input p {
  margin: 0 0 21px 0;
}
.purcuahseorder .purcuahseorder-input textarea {
  font: 400 14px/21px "proxima-nova", sans-serif;
  box-sizing: border-box;
  outline: none;
  border: none;
  background: none;
  width: 100%;
  height: 100%;
  min-height: 315px;
  resize: none;
}
.purcuahseorder .purcuahseorder-header {
  border-bottom: 1px solid #dedfe3;
  padding: 0px 0 15px 0;
}
.purcuahseorder .purcuahseorder-header .purcuahseorder-date {
  float: right;
  margin: 10px 0 0 0;
}
.purcuahseorder .purcuahseorder-header .purcuahseorder-number {
  float: left;
  margin: 10px 0 0 0;
}
.purcuahseorder .purcuahseorder-header .purcuahseorder-number .number {
  color: #ea4e1b;
  font-size: 18px;
}
.purcuahseorder .purcuahseorder-header .purcuahseorder-address {
  float: left;
  font-style: normal;
  color: #a1a8c2;
  font-size: 14px;
  margin: 0 0 0 25px;
  border-left: 1px solid #dedfe3;
  padding: 5px 0 5px 10px;
}


    </style>
</head>
<body>
	<div class="card purcuahseorder saved" id="purcuahseorder">
        <div class="purcuahseorder-header clear">
          <div class="purcuahseorder-number">
            <div class="text-label">Purchase Order</div>
            <div class="number">'+ponumber+'</div>
          </div>
          <div class="purcuahseorder-address">
            The Emporium<br>47 Main Street<br>Ottawa, Ontario K1S 1B1
          </div>
          <div class="purcuahseorder-date">
            <div class="text-label">Date</div>
            <div class="date">'+@purchase_order.date.strftime("%B #{@purchase_order.date.day.ordinalize}, %Y")+'</div>
          </div>
        </div>
        <div class="purcuahseorder-vendor clear">
          <div class="to">
            Send To
          </div>
          <div class="vendor-select">
            <div class="vendor-details">'+@purchase_order.vendor.name+'<br>Attention: '+@purchase_order.vendor.contact+'<br>'+@purchase_order.vendor.email+'</div>
          </div>
        </div>
        <div class="purcuahseorder-input">'+simple_format(@purchase_order.description)+'</div>
      </div>
</body>
</html>'
		#randomly generate file name so we don't have file name collisions
		file_name = [*100000..999999].sample.to_s
		File.open(file_name, "w+b") do |f|
		  f.write DocRaptor.create(:document_content => pdf_html,
		                           :name             => file_name,
		                           :document_type    => "pdf",
		                           :test             => true)
		end

		#add attachment, renamed
		attachments['purchase_order_'+@purchase_order.number.to_s+'.pdf'] = File.read(file_name)
		#send email with pdf attachment
		mail(to: @purchase_order.vendor.email, subject: 'Purchase Order '+@purchase_order.number.to_s)
		#delete local file
		File.delete(file_name)
	end


end
