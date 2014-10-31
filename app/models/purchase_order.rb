class PurchaseOrder
  include Mongoid::Document
  field :number, type: Integer
  field :date, type: Time
  field :status, type: String
  field :description, type: String
  field :purchasing_agent, type: String
end
