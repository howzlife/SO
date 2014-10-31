class Vendor
  include Mongoid::Document
  field :name, type: String
  field :address, type: String
  field :telephone, type: String

  has_many :purchase_orders, autosave: true
end
