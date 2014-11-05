class Vendor
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :contact, type: String
  field :telephone, type: String


  validates_presence_of :name, :email, :contact, :telephone

  has_many :purchase_orders, autosave: true

  accepts_nested_attributes_for :purchase_orders

end
