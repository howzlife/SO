class PurchaseOrder
  include Mongoid::Document
  field :number, type: Integer, default: -> { [*100000..999999].sample }
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :purchasing_agent, type: String

  validates_presence_of :number, :date, :purchasing_agent

  belongs_to :vendor
end
