json.array!(@faxes) do |fax|
  json.extract! fax, :id, :recipient_name, :company_name, :fax_number, :subject, :content
  json.url fax_url(fax, format: :json)
end
