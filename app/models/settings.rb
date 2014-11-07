class Settings
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :fax, type: String
  field :telephone, type: String


  validates_presence_of :name, :email, :fax, :telephone

  has_many :addresses

  accepts_nested_attributes_for :addresses

end
