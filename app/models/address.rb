class Address
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :address, type: Hash
  field :telephone, type: String
  field :fax, type: String
  field :agent, type: String

  validates_presence_of :name

  belongs_to :company

  embedded_in :addressable, polymorphic: true


  def self.search(company_id, search)
    if search
      where(company_id: company_id).any_of({name: /#{search}/i}, {address: /#{search}/i}, {agent: /#{search}/i})
    end
  end

end
