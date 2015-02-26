class Address
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :address, type: Hash
  field :telephone, type: String
  field :fax, type: String
  field :agent, type: String
  field :state, type: String
  field :defaultflag, type: Boolean

  validates_presence_of :name

  embedded_in :addressable, polymorphic: true
end
