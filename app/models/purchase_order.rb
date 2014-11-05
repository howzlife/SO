class PurchaseOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :number, type: Integer, default: -> { [*100000..999999].sample }
  field :date, type: DateTime, default: ->{ DateTime.current } 
  field :status, type: String
  field :description, type: String
  field :purchasing_agent, type: String

  validates_presence_of :number, :date, :purchasing_agent

  belongs_to :vendor


  def self.search(search)
    if search
      any_of({number: /#{search}/i}, {status: /#{search}/i}, {description: /#{search}/i}, {purchasing_agent: /#{search}/i})
    end
  end

end
