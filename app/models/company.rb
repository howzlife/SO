class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :fax, type: Integer
  field :sending_telephone, type: Integer
  field :location_name, type: String
  field :address, type: String
  field :receiving_telephone, type: Integer
  field :receiving_agent, type: String

  has_many :users
  has_many :purchase_orders
  embeds_many :vendors, as: :vendorable

  accepts_nested_attributes_for :purchase_orders, :users, :vendors
end
