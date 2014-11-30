class PurchaseOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :number, type: String
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :tags, type: String
  field :date_required, type: String
  field :label, type: String
  field :archived, type: Boolean

  validates_presence_of :number, :date, :description, :vendor

  embeds_one :vendor, as: :vendorable, autobuild: true
  embeds_many :comments
  embeds_one :address, as: :addressable, autobuild: true

  belongs_to :company

  accepts_nested_attributes_for :vendor

  def self.search(company_id, search)
    if search
      where(company_id: company_id).any_of({number: /#{search}/i}, {status: /#{search}/i}, {description: /#{search}/i}, {label: /#{search}/i}, {"vendor.name" => /#{search}/i}, {"vendor.email" => /#{search}/i}, {"vendor.contact" => /#{search}/i}, {"vendor.telephone" => /#{search}/i})
    end
  end

  def self.status(company_id, status)
    if status
      where(company_id: company_id, status: status)
    end
  end

  def self.label(company_id, label)
    if label
      where(company_id: company_id, label: label)
    end
  end

  def self.archived(company_id)
    where(company_id: company_id, archived: true)
  end
end
