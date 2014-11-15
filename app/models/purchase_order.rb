class PurchaseOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :number, type: Integer, default: -> { [*100000..999999].sample }
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :tags, type: String
  field :date_required, type: String

  validates_presence_of :number, :date, :description, :vendor

  embeds_one :vendor, as: :vendorable, autobuild: true
  embeds_many :comments

  belongs_to :company

  accepts_nested_attributes_for :vendor

  def self.search(search)
    if search
      any_of({number: /#{search}/i}, {status: /#{search}/i}, {description: /#{search}/i}, {tags: /#{search}/i})
    end
  end

end
