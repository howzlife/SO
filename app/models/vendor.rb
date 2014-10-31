class Vendor
  include Mongoid::Document
  field :name, type: String
  field :address, type: String
  field :contact, type: String
  field :telephone, type: String
end
