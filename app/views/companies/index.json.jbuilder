json.array!(@companies) do |company|
  json.extract! company, :id, :name, :email, :fax, :telephone, :location_name, :address, :receiving_telephone, :receiving_agent
  json.url company_url(company, format: :json)
end
