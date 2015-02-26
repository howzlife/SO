class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :sendfromname, type: String
  field :email, type: String
  field :fax, type: String
  field :telephone, type: String
  field :prefix, type: String


  has_many :users
  has_many :purchase_orders do
    def active()
      excludes(archived: true)
    end
  end
  
  embeds_many :vendors, as: :vendorable do
    def search(search)
      any_of({name: /#{search}/i}, {email: /#{search}/i}, {contact: /#{search}/i}, {telephone: /#{search}/i})
    end
  end
  
  embeds_many :addresses, as: :addressable

  embeds_many :labels do
    def search(search)
      any_of({name: /#{search}/i}).descending(:updated_at).to_json
    end
  end

  accepts_nested_attributes_for :addresses, :purchase_orders, :users, :vendors
end
