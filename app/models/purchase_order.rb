class PurchaseOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :number, type: Integer, default: -> { [*100000..999999].sample }
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :tags, type: String

  validates_presence_of :number, :date, :description, :vendor

  belongs_to :vendor

  embeds_many :comment

  def self.search(search)
    if search
      any_of({number: /#{search}/i}, {status: /#{search}/i}, {description: /#{search}/i}, {tags: /#{search}/i})
    end
  end

end
