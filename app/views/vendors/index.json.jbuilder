json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :name, :address, :telephone
  json.url vendor_url(vendor, format: :json)
end
