class Label
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String

  validates_presence_of :name

  embedded_in :company

end
