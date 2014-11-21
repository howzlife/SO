class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :fax, type: String
  field :telephone, type: String
  field :prefix, type: String

  validates_presence_of :name, :email, :fax, :telephone, :prefix

  has_many :users
  has_many :purchase_orders
  embeds_many :vendors, as: :vendorable
  embeds_many :addresses, class_name: "Address"

  accepts_nested_attributes_for :addresses, :purchase_orders, :users, :vendors
end
