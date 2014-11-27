module ApplicationHelper

	#add a current class if the section is the current section
	def cp(path)
		"current" if request.url.include?(path) || (request.url.include?('addresses') && path == company_path(@company) )
	end

	#add a current class if the search path is the current path
	def sp(path)
		"current" if request.url.include?(path) || (!params.has_key?(:status) && path == "all" && !params.has_key?(:label))
	end

end
