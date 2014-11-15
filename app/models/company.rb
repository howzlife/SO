class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :fax, type: Integer
  field :telephone, type: Integer

  has_many :users
  has_many :purchase_orders
  embeds_many :vendors, as: :vendorable
  embeds_many :addresses

  accepts_nested_attributes_for :purchase_orders, :users, :vendors
end
