require 'rubygems'
require 'doc_raptor'

class SendPDF

	def initialize(email)
		pdf_html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html lang="en"><body><a href="http://google.com">google</a></body></html>'
		File.open("doc_raptor_sample.pdf", "w+b") do |f|
		  f.write DocRaptor.create(:document_content => pdf_html,
		                           :name             => "docraptor_sample.pdf",
		                           :document_type    => "pdf",
		                           :test             => true)
		end
	end

end