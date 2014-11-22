class Address
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :address, type: String
  field :telephone, type: String
  field :agent, type: String
  field :defaultflag, type: Boolean

  validates_presence_of :name, :address

  embedded_in :company
end
