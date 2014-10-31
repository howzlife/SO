class PurchaseOrder
  include Mongoid::Document
  field :number, type: Integer, default: -> { [*1000..100000].sample }
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :purchasing_agent, type: String
end
