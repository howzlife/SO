class Vendor
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :contact, type: String
  field :telephone, type: String


  validates_presence_of :name, :email, :contact, :telephone

  embedded_in :vendorable, polymorphic: true



end
