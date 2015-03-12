json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :name, :email, :contact, :telephone, :fax
end
