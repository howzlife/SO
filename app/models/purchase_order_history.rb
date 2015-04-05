class PurchaseOrderHistory

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :action, type: String
  field :date, type: DateTime, default: ->{ DateTime.current } 

  embedded_in :trackable
  
end
