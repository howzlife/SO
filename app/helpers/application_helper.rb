module ApplicationHelper

	#add a current class if the section is the current section
	def cp(path)
		"current" if request.url.include?(path)
	end

end
