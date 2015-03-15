json.array!(@purchase_orders) do |purchase_order|
  json.extract! purchase_order, :id, :number, :date, :status, :vendor, :label, :archived
end
