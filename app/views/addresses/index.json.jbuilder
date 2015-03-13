json.array!(@addresses) do |address|
  json.extract! address, :id, :name, :address, :telephone, :agent
end
