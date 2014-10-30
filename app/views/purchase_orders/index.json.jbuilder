json.array!(@purchase_orders) do |purchase_order|
  json.extract! purchase_order, :id, :number, :date, :status, :description, :purchasing_agent
  json.url purchase_order_url(purchase_order, format: :json)
end
