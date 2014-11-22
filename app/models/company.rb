class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :fax, type: String
  field :telephone, type: String
  field :prefix, type: String


  has_many :users
  has_many :purchase_orders
  embeds_many :vendors, as: :vendorable do
    def find_by_name(name)
      where(name: name).first
    end
  end
  
  embeds_many :addresses, class_name: "Address"

  accepts_nested_attributes_for :addresses, :purchase_orders, :users, :vendors
end
