require 'doc_raptor'
DocRaptor.api_key "ydVvQdh5knSYuG8yZkS"

class FAXMailer < ActionMailer::Base
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::TextHelper

  def save_pdf(fax, user, bcc)

		#create instance variables
    @recipient = fax.recipient_name
    @number    = fax.fax_number
    @subject = fax.subject
    @content = fax.content

  	#create PDFS
	  pdf_html = "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv='content-type' content='text/html; charset=utf-8' />
    <style type='text/css'>
    @page {
    	margin: 30px; background: #ffffff;
			@bottom { 
          content: 'Swiftorders takes the pain out of business purchasing. • Swiftorders.com • Try it free for 30 days.';
          font-size: 7px; color: #3895d9; font-family: sans-serif;
        }
    }
h4 {
  font-size: 12px;
  font-weight: 600;
  margin: 0 0 10px 0;
}
</style>
</head>
<header>
<h4>From: " + user.first_name + " " + user.last_name + "</h4><br>
<h4>To: " +  @recipient + "</h4><br>
<h4>Subject: " + @subject + "</h4><br>
</header>
<body>
	<div>
    <p>" + @content + "</p>
  </div>
</body>
</html>"
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

    #bcc if checkbox is selected
    if bcc
      mail(to: current_user.email, subject: 'Purchase Order '+@purchase_order.number.to_s, from: @company.email, reply_to: @company.email)
    end

		return pdf_html, file_name

	end


end
