class Address
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :address, type: String
  field :telephone, type: String
  field :agent, type: String
  field :defaultflag, type: Boolean


  embedded_in :company

end
