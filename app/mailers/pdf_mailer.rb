require 'doc_raptor'

class PDFMailer < ActionMailer::Base
  default from: "from@example.com"

  def send_pdf(purchase_order)

		#create instance variables
		@purchase_order = purchase_order

  	#create PDFS
	  pdf_html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html lang="en"><head> <style> table, th, td { border: 1px solid black; } </style> </head><body> <table> <tr> <th>Purchase Order</th> <th>Address</th> <th>Date</th> </tr> <tr> <td>'+@purchase_order.number.to_s+'</td> <td>123 Any Street</td> <td>'+@purchase_order.date.strftime("%B #{@purchase_order.date.day.ordinalize}, %Y")+'</td> </tr> <tr> <td><b>Send To</b></td> <td colspan="2">123 Another Street</td> </tr> <tr> <td colspan="3">'+@purchase_order.description+'</td> </tr> </table></body></html>'
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
